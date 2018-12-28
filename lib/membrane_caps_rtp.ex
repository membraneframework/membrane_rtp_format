defmodule Membrane.Caps.RTP do
  @moduledoc """
  This module provides caps struct for RTP packet.
  """

  @typedoc """
  RTP Payload type as a number.
  """
  @type raw_payload_type :: 0..127

  @typedoc """
  Predefined static payload types.
  """
  @type static_payload_type ::
          :pcmu
          | :gsm
          | :g732
          | :dvi4
          | :dvi4
          | :lpc
          | :pcma
          | :g722
          | :l16
          | :l16
          | :qcelp
          | :cn
          | :mpa
          | :g728
          | :dvi4
          | :dvi4
          | :g729
          | :celb
          | :jpeg
          | :nv
          | :h261
          | :mpv
          | :mp2t
          | :h263

  @typedoc """
  Value designating that dynamic type should be used.
  """
  @type dynamic_payload_type :: :dynamic

  @typedoc """
  RTP payload type as an atom. Only for static payload types.
  """
  @type payload_type :: static_payload_type() | dynamic_payload_type()

  @typedoc """
  The source of a stream of RTP packets, identified by a 32-bit numeric identifier.
  """
  @type ssrc :: pos_integer()

  @type t :: %__MODULE__{
          payload_type: payload_type(),
          raw_payload_type: raw_payload_type()
        }

  @enforce_keys [:payload_type, :raw_payload_type]
  defstruct @enforce_keys
end
