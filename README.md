ISO 3166 JSON
=============
![Auto Update Country Data](https://github.com/itay-grudev/iso-3166-json/workflows/Auto%20Update%20Country%20Data/badge.svg?event=schedule)

This repository represents a collection of all sorts of useful information for every country in the ISO 3166 standard. It contains info for the following standards ISO3166-1 (countries), ISO3166-2 (states/subdivisions), ISO4217 (currency) and E.164 (phone numbers).

It is based on data automatically extracted and converted from the Ruby project [`gem countries`](https://github.com/hexorx/countries)

The project is intended to be used as a git submodule in other projects that rely on this data. It is designed so that it updates itself and follows the `hexorx/countries` repository for updates automatically.

See Also
--------

### [ISO 3166 YAML](https://github.com/itay-grudev/iso-3166-yaml)


Copyright
---------

Copyright (c) 2020 Itay Grudev. This script used for automating the data collection is released under The MIT License (MIT), while the data is released as specified in the `data/LICENSE` and is also distributed under the MIT license as of now.
