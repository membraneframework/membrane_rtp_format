# Membrane Multimedia Framework: RTP format description

[![CircleCI](https://circleci.com/gh/membraneframework/membrane_rtp_format.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_rtp_format)

This package provides structures describing RTP/RTCP streams. They can be used to define capabilities of pads for the [Membrane](https://membraneframework.org) Elements.

## Installation

Unless you're developing an Membrane Element it's unlikely that you need to use this package directly in your app, as normally it is going to be fetched as a dependency of any element that operates on RTP packets.

However, if you are developing an Element or need to add it due to any other reason, just add the following line to your `deps` in the `mix.exs` and run `mix deps.get`.

```elixir
{:membrane_rtp_format, "~> 0.1"}
```

## Copyright and License

Copyright 2018, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rtp_format)

[![Software Mansion](https://membraneframework.github.io/static/logo/swm_logo_readme.png)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rtp_format)

Licensed under the [Apache License, Version 2.0](LICENSE)
