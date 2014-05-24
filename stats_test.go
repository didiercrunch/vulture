package main

import (
	"testing"
)

func TestNewStats(t *testing.T) {
	s := NewStatAggregator()
	if s.n != 0 ||
		s.sum != 0 ||
		s.sumOfTheSquares != 0 ||
		len(s.histogram) != initialLength ||
		s.min != veryBig ||
		s.max != verySmall {
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

func TestGetFinalStats(t *testing.T) {
	s := NewStatAggregator()
	s.sumOfTheSquares = 5000
	s.max = 900
	s.min = -900
	s.sum = 200
	s.n = 10
	stats := s.getFinalStats()
	if stats.Mean != 20. {
		t.Fail()
	}
	if stats.Var != 100. {
		t.Fail()
	}
	if stats.Std != 10. {
		t.Fail()
	}
	if stats.Min != -900 {
		t.Fail()
	}
	if stats.Max != 900 {
		t.Fail()
	}
	if stats.N != 10 {
		t.Fail()
	}
}

func TestFindSuitableBinForDatum(t *testing.T) {
	stats := new(HistogramMaker)
	if bin := stats.findSuitableBinForDatum(-4, 1, -3.2); bin != 0 {
		t.Error("wrong bin: ", bin)
	}

	if bin := stats.findSuitableBinForDatum(-4, 1, -2.2); bin != 1 {
		t.Error("wrong bin: ", bin)
	}

	if bin := stats.findSuitableBinForDatum(-4, 1, 10.1); bin != 14 {
		t.Error("wrong bin: ", bin)
	}
	if bin := stats.findSuitableBinForDatum(1, 50, 1); bin != 0 {
		t.Error("wrong bin: ", bin)
	}

}
