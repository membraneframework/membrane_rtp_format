defmodule Membrane.Caps.RTP.PayloadTypeDecoder do
  alias Membrane.Caps.RTP

  @typedoc """
  Predefined static payload types
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
  Value designating that dynamic type should be used
  """
  @type dynamic_payload_type :: :dynamic

  @type payload_type :: static_payload_type() | dynamic_payload_type()

  @doc """
  Decodes numerical payload type to atom.
  """
  @spec decode_payload_type(payload_type :: RTP.raw_payload_type()) :: payload_type()
  def decode_payload_type(type)
  def decode_payload_type(0), do: :pcmu
  def decode_payload_type(3), do: :gsm
  def decode_payload_type(4), do: :g732
  def decode_payload_type(5), do: :dvi4
  def decode_payload_type(6), do: :dvi4
  def decode_payload_type(7), do: :lpc
  def decode_payload_type(8), do: :pcma
  def decode_payload_type(9), do: :g722
  def decode_payload_type(10), do: :l16
  def decode_payload_type(11), do: :l16
  def decode_payload_type(12), do: :qcelp
  def decode_payload_type(13), do: :cn
  def decode_payload_type(14), do: :mpa
  def decode_payload_type(15), do: :g728
  def decode_payload_type(16), do: :dvi4
  def decode_payload_type(17), do: :dvi4
  def decode_payload_type(18), do: :g729
  def decode_payload_type(25), do: :celb
  def decode_payload_type(26), do: :jpeg
  def decode_payload_type(28), do: :nv
  def decode_payload_type(31), do: :h261
  def decode_payload_type(32), do: :mpv
  def decode_payload_type(33), do: :mp2t
  def decode_payload_type(34), do: :h263

  def decode_payload_type(payload_type) when payload_type in 0..127, do: :dynamic
end
