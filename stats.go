package main

import (
	"fmt"
	"log"
	"math"
)

var _ = fmt.Print

const initialLength int = 1024
const verySmall float64 = -100000
const veryBig float64 = 100000

type Histogram struct {
	Min      float64 `json:"min"`
	StepSize float64 `json:"step_size"`
	Values   []int   `json:"values"`
}

type HistogramMaker struct {
	Min          float64
	Max          float64
	NumberOfBins int
}

func (this *HistogramMaker) findSuitableBinForDatum(min, step, val float64) int {
	var i int
	var act float64 = min
	for i = 0; act <= val; act += step {
		i++
	}
	return i - 1

}

func (this *HistogramMaker) MakeHistogram(dataChannel chan float64, outputChannel chan *Histogram) {

	step := (this.Max - this.Min) / float64(this.NumberOfBins)
	hist := make([]int, this.NumberOfBins)

	for datum := range dataChannel {
		if datum < this.Min || datum > this.Max {
			continue
		}
		i := this.findSuitableBinForDatum(this.Min, step, datum)
		if i >= len(hist) || i < 0 {
			log.Println("bad bin format", this.Min, step, datum, i)
		} else {
			hist[i]++
		}
	}

	outputChannel <- &Histogram{this.Min, step, hist}

}

type Stats struct {
	Mean float64 `json:"mean"`
	Var  float64 `json:"var"`
	Std  float64 `json:"std"`
	Min  float64 `json:"min"`
	Max  float64 `json:"max"`
	N    int     `json:"n"`
}

type StatAggregator struct {
	sum             float64
	sumOfTheSquares float64
	n               int
	histogram       []float64
	min             float64
	max             float64
}

func NewStatAggregator() *StatAggregator {
	return &StatAggregator{0, 0, 0, make([]float64, initialLength), veryBig, verySmall}
}

func (this *StatAggregator) AddStats(dataChannel chan float64, output chan *Stats) {
	for datum := range dataChannel {
		this.sum += datum
		this.sumOfTheSquares += datum * datum
		this.n += 1
		if datum < this.min {
			this.min = datum
		}
		if datum > this.max {
			this.max = datum
		}
	}
	output <- this.getFinalStats()
}

func (this *StatAggregator) getFinalStats() *Stats {
	stats := new(Stats)
	stats.Mean = this.sum / float64(this.n)
	stats.Var = this.sumOfTheSquares/float64(this.n) - stats.Mean*stats.Mean
	stats.Std = math.Sqrt(stats.Var)
	stats.Min = this.min
	stats.Max = this.max
	stats.N = this.n

	return stats
}
