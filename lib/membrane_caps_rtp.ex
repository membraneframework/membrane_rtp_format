defmodule Membrane.Caps.RTP do
  @moduledoc """
  This module provides caps struct for RTP packet.
  """

  @typedoc """
  RTP Payload type as number.
  """
  @type raw_payload_type :: 0..127

  @typedoc """
  RTP payload type as atom. Only for static payload types.
  """
  @type payload_type :: atom()

  @typedoc """
  The source of a stream of RTP packets, identified by a 32-bit numeric identifier.
  """
  @type ssrc :: pos_integer()

  @type t :: %__MODULE__{
          payload_type: payload_type(),
          ssrc: ssrc(),
          raw_payload_type: payload_type()
        }
  defstruct [:payload_type, :raw_payload_type, :ssrc]
end
