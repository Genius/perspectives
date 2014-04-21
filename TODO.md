# TODO
* DONE Files should be a wrapped collection that knows how to render itself
* DONE-ish What to do about flash? (maybe port from RailsGenius?)
* DONE Need a generator that sets up the MustacheCompiler front-end stuff and requires the javascript library
* DONE Generators
* Need cache multiget for nested collections
* Fallbacks for history api in other browsers (some kind of modernizr situation?)
* Examples!
* Tests in multiple ruby/rails versions
    * Ruby 1.8 / 1.9 / 2.1
    * Rails 2.3, 3.2, 4.0
* Mat's idea of conditionally cached properties
* Have to have a way for cache keys to not be aggregated together (performance optimization if you don't want to load a ton of records)