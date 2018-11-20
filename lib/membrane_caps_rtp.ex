defmodule Membrane.Caps.RTP do
  @moduledoc """
  This module provides caps struct for RTP packet.
  """

  @typedoc """
  Standarized payload type id
  """
  @type payload_type :: pos_integer()

  @type t :: %__MODULE__{
          payload_type: payload_type()
        }
  defstruct [:payload_type]
end
