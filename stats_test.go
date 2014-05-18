package main

import (
	"reflect"
	"testing"
)

func TestNewStats(t *testing.T) {
	s := NewStatAggregator()
	if s.n != 0 ||
		s.sum != 0 ||
		s.sumOfTheSquares != 0 ||
		s.numberOfHistogramBar != initialLength ||
		s.min != veryBig ||
		s.max != verySmall ||
		len(s.histogram) != 0 ||
		len(s.histogramValues) != 0 {
		t.Fail()
	}
}

func TestAddStatsBasic(t *testing.T) {

	numbers := []float64{-1, 1, 20, 3}
	c := make(chan float64)
	o := make(chan *Stats)
	s := NewStatAggregator()
	go s.AddStats(c, o)
	for _, n := range numbers {
		c <- n
	}
	close(c)
	<-o
	if s.n != 4. || s.min != -1. || s.max != 20. || s.sum != 23. || s.sumOfTheSquares != 411. {
		t.Error(">>>", s.max, s.min)
	}
}

func TestAddDataToHistogramWhenLessDataThanBarAreOnHistograms(t *testing.T) {
	s := NewStatAggregator()
	s.AddDataToHistogramWhenLessDataThanBarAreOnHistograms(17)
	if !reflect.DeepEqual([]float64{17}, s.histogram) {
		t.Error("bad histogram", s.histogram)
	}
	if !reflect.DeepEqual([]int{1}, s.histogramValues) {
		t.Error("bad histogramValues:", s.histogramValues)
	}
	s.histogram = []float64{-1, 1, 2, 3}
	s.histogramValues = []int{1, 1, 1, 1}
	s.AddDataToHistogramWhenLessDataThanBarAreOnHistograms(2)
	if !reflect.DeepEqual([]int{1, 1, 2, 1}, s.histogramValues) {
		t.Error("bad histogramValues", s.histogramValues)
	}

	s.AddDataToHistogramWhenLessDataThanBarAreOnHistograms(2.5)
	if !reflect.DeepEqual([]float64{-1, 1, 2, 2.5, 3}, s.histogram) {
		t.Error("bad histogram", s.histogram)
	}
	if !reflect.DeepEqual([]int{1, 1, 2, 1, 1}, s.histogramValues) {
		t.Error("bad histogramValues:", s.histogramValues)
	}

	s.AddDataToHistogramWhenLessDataThanBarAreOnHistograms(22.5)
	if !reflect.DeepEqual([]float64{-1, 1, 2, 2.5, 3, 22.5}, s.histogram) {
		t.Error("bad histogram", s.histogram)
	}
	if !reflect.DeepEqual([]int{1, 1, 2, 1, 1, 1}, s.histogramValues) {
		t.Error("bad histogramValues:", s.histogramValues)
	}

}

func TestAddDataToHistogramWithMaximalNumberOfBars(t *testing.T) {
	s := NewStatAggregator()
	s.numberOfHistogramBar = 5
	s.histogram = []float64{1, 2, 3, 4, 5}
	s.histogramValues = []int{1, 1, 2, 3, 4}
	s.AddDataToHistogramWithMaximalNumberOfBars(3.5)
	if !reflect.DeepEqual(s.histogram, []float64{1, 2, 3, 4, 5}) {
		t.Fail()
	}
	if !reflect.DeepEqual(s.histogramValues, []int{1, 1, 2, 3, 4}) {
		t.Fail()
	}
}
