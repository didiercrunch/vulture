package main

import (
	"fmt"
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

type Stats struct {
	Mean float64 `json:"mean"`
	Var  float64 `json:"var"`
	Std  float64 `json:"std"`
	Min  float64 `json:"min"`
	Max  float64 `json:"max"`
	N    int     `json:"n"`
}

func (this *Stats) findMinHistogramValue() float64 {
	return math.Max(this.Min, this.Mean-3*this.Std)
}

func (this *Stats) findMaxHistogramValue() float64 {
	return math.Min(this.Max, this.Mean+3*this.Std)
}

func (this *Stats) findSuitableBinForDatum(min, step, val float64) int {
	var i int
	var act float64 = min
	for i = 0; act < val; act += step {
		i++
	}
	return i - 1

}

func (this *Stats) MakeHistogram(numberOfBins int, dataChannel chan float64, outputChannel chan *Histogram) {
	min := this.findMinHistogramValue()
	max := this.findMaxHistogramValue()
	step := (max - min) / float64(numberOfBins)
	hist := make([]int, numberOfBins)

	for datum := range dataChannel {
		if datum < min || datum > max {
			continue
		}
		i := this.findSuitableBinForDatum(min, step, datum)
		hist[i]++
	}

	outputChannel <- &Histogram{min, step, hist}

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
