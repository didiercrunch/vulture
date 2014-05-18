package main

import (
	"fmt"
	"math"
)

var _ = fmt.Print

const initialLength int = 1024
const verySmall float64 = -100000
const veryBig float64 = 100000
const epsilon = 0.00000002

type StatAggregator struct {
	sum             float64
	sumOfTheSquares float64
	n               int
	// histogram is a list of point between [min max] each point in the
	//histogram represents the beginning of the histogram bars.
	histogram            []float64
	histogramValues      []int
	histogramBarWidth    float64
	numberOfHistogramBar int
	min                  float64
	max                  float64
}

type Stats struct{}

func NewStatAggregator() *StatAggregator {
	return &StatAggregator{0,
		0,
		0,
		make([]float64, 0, initialLength),
		make([]int, 0, initialLength),
		0,
		initialLength,
		veryBig,
		verySmall}
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
	output <- nil
}

//  always assume the min and max includes the value!
func (this *StatAggregator) AddDataToHistogram(value float64) {
	if len(this.histogramValues) < this.numberOfHistogramBar {
		this.AddDataToHistogramWhenLessDataThanBarAreOnHistograms(value)
	} else {
		this.AddDataToHistogramWithMaximalNumberOfBars(value)

	}

}

func (this *StatAggregator) AddDataToHistogramWithMaximalNumberOfBars(value float64) {
}

func (this *StatAggregator) AddDataToHistogramWhenLessDataThanBarAreOnHistograms(value float64) {
	for i, v := range this.histogram {
		if math.Abs(value-v) < epsilon {
			this.histogramValues[i]++
			return
		} else if value < v {
			this.histogram = append(this.histogram, 0)
			copy(this.histogram[i+1:], this.histogram[i:])
			this.histogram[i] = value

			this.histogramValues = append(this.histogramValues, 0)
			copy(this.histogramValues[i+1:], this.histogramValues[i:])
			this.histogramValues[i] = 1
			return
		}
	}
	this.histogramValues = append(this.histogramValues, 1)
	this.histogram = append(this.histogram, value)
}
