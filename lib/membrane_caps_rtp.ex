defmodule Membrane.Caps.RTP do
  @moduledoc """
  This module provides caps struct for RTP packet.
  """

  @typedoc """
  Standarized payload type id
  """
  @type payload_type :: pos_integer()

  @type clock_rate :: pos_integer()

  @type t :: %__MODULE__{
          payload_type: payload_type(),
          clock_rate: clock_rate()
        }
  defstruct [:payload_type, :clock_rate]
end
