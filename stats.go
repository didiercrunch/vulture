package main

import (
	"fmt"
)

var _ = fmt.Print

const initialLength int = 1024
const verySmall float64 = -100000
const veryBig float64 = 100000

type StatAggregator struct {
	sum             float64
	sumOfTheSquares float64
	n               int
	histogram       []float64
	min             float64
	max             float64
}

type Stats struct{}

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
	output <- nil
}
