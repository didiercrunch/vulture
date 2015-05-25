# Vulture ![super cool vulture logo](client/images/vulture.png)

An advanced [MongoDB](http://www.mongodb.org/) data viewers in a web interface.  the
project is inspired by [mongs](http://whit537.org/mongs/) but has additional features.

*   Support for [GeoJson](http://geojson.org/) indexes.
*   View basic statistics
*   Easy filtering support
*   Support of the [aggregation pipeline](http://docs.mongodb.org/manual/core/aggregation-pipeline/)
    framework!

### run vulture

1.  Download your binaries
   *  [windows](https://dl.bintray.com/didiercrunch/generic/vulture_1.2.1-vulture_windows_amd64.zip)
   *  [mac](https://dl.bintray.com/didiercrunch/generic/vulture_1.2.1-vulture_darwin_amd64.zip)
   *  [linux](https://dl.bintray.com/didiercrunch/generic/vulture_1.2.1-vulture_linux_amd64.tar.gz)

2.  Unzip the file

3.  run the `vulture` (or vulture.exe) executable.


### params

You can add mongodb servers or change the vulture listening port in the
*params.yml* file.


### screenshots

|                                |                               |
| ------------------------------ |:-----------------------------:|
| ![general view][general_view]  | ![geojson view][geojson_view] |
| ![stat view][stats_view]  | ![key view][key_view] |



[general_view]: https://raw.githubusercontent.com/didiercrunch/vulture/master/screenshots/general.png
[geojson_view]: https://raw.githubusercontent.com/didiercrunch/vulture/master/screenshots/geo.png
[stats_view]: https://raw.githubusercontent.com/didiercrunch/vulture/master/screenshots/stats.png
[key_view]: https://raw.githubusercontent.com/didiercrunch/vulture/master/screenshots/key.png


### coding style

The coding standard is very low.  Unfortunatly. there are very few tests.  If the project
triggers enough enthusiasm, I'll make more tests.
