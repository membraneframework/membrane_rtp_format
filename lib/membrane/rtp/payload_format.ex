defmodule Membrane.RTP.PayloadFormat do
  @moduledoc """
  This module contains utilities for resolving RTP default payload types,
  encoding names, clock rates and (de)payloaders.
  """

  alias Membrane.RTP

  require Membrane.RTP

  @app :membrane_rtp_format

  @payload_types_specs %{
    0 => %{encoding_name: :PCMU, clock_rate: 8000},
    3 => %{encoding_name: :GSM, clock_rate: 8000},
    4 => %{encoding_name: :G732, clock_rate: 8000},
    5 => %{encoding_name: :DVI4, clock_rate: 8000},
    6 => %{encoding_name: :DVI4, clock_rate: 16000},
    7 => %{encoding_name: :LPC, clock_rate: 8000},
    8 => %{encoding_name: :PCMA, clock_rate: 8000},
    9 => %{encoding_name: :G722, clock_rate: 8000},
    10 => %{encoding_name: :L16, clock_rate: 44100},
    11 => %{encoding_name: :L16, clock_rate: 44100},
    12 => %{encoding_name: :QCELP, clock_rate: 8000},
    13 => %{encoding_name: :CN, clock_rate: 8000},
    14 => %{encoding_name: :MPA, clock_rate: 90000},
    15 => %{encoding_name: :G728, clock_rate: 8000},
    16 => %{encoding_name: :DVI4, clock_rate: 11025},
    17 => %{encoding_name: :DVI4, clock_rate: 22050},
    18 => %{encoding_name: :G729, clock_rate: 8000},
    25 => %{encoding_name: :CELB, clock_rate: 90000},
    26 => %{encoding_name: :JPEG, clock_rate: 90000},
    28 => %{encoding_name: :NV, clock_rate: 90000},
    31 => %{encoding_name: :H261, clock_rate: 90000},
    32 => %{encoding_name: :MPV, clock_rate: 90000},
    33 => %{encoding_name: :MP2T, clock_rate: 90000},
    34 => %{encoding_name: :H263, clock_rate: 90000}
  }

  @enforce_keys [:encoding_name]
  defstruct @enforce_keys ++ [payload_type: nil, payloader: nil, depayloader: nil]

  @type t :: %__MODULE__{
          encoding_name: RTP.encoding_name_t(),
          payload_type: RTP.payload_type_t() | nil,
          payloader: module | nil,
          depayloader: module | nil
        }

  @doc false
  @spec register_static_formats() :: :ok
  def register_static_formats() do
    @payload_types_specs
    |> Enum.group_by(fn {_pt, specs} -> specs.encoding_name end, fn {pt, _specs} -> pt end)
    |> Enum.each(fn
      {name, [pt]} -> register(%__MODULE__{encoding_name: name, payload_type: pt})
      _ambiguous -> :ok
    end)
  end

  @doc """
  Returns encoding name and clock rate for given payload type, if registered.
  """
  @spec get_payload_type_mapping(RTP.payload_type_t()) :: %{
          optional(:encoding_name) => RTP.encoding_name_t(),
          optional(:clock_rate) => RTP.clock_rate_t()
        }
  def get_payload_type_mapping(payload_type) when RTP.is_payload_type_static(payload_type) do
    Map.fetch!(@payload_types_specs, payload_type)
  end

  def get_payload_type_mapping(payload_type) when RTP.is_payload_type_dynamic(payload_type) do
    Application.get_env(@app, {:payload_type_mapping, payload_type}, %{})
  end

  @doc """
  Registers default encoding name and clock rate for a dynamic payload_type
  """
  @spec register_payload_type_mapping(
          RTP.dynamic_payload_type_t(),
          RTP.encoding_name_t(),
          RTP.clock_rate_t()
        ) :: :ok | no_return()
  def register_payload_type_mapping(payload_type, encoding_name, clock_rate)
      when RTP.is_payload_type_dynamic(payload_type) do
    case Application.fetch_env(@app, {:payload_type_mapping, payload_type}) do
      {:ok, payload_format} ->
        raise "RTP payload type #{payload_type} already registered: #{inspect(payload_format)}"

      :error ->
        Application.put_env(@app, {:payload_type_mapping, payload_type}, %{
          encoding_name: encoding_name,
          clock_rate: clock_rate
        })
    end
  end

  @doc """
  Returns payload format registered for given encoding name.
  """
  @spec get(RTP.encoding_name_t()) :: t
  def get(encoding_name) do
    Application.get_env(@app, {:format, encoding_name}, %__MODULE__{encoding_name: encoding_name})
  end

  @doc """
  Registers payload format.

  Raises if some payload format field was already registered and set to different value.
  """
  @spec register(t) :: :ok | no_return
  def register(%__MODULE__{encoding_name: encoding_name} = payload_format) do
    payload_format =
      Application.get_env(@app, {:format, encoding_name}, %{})
      |> Map.merge(payload_format, &merge_format(encoding_name, &1, &2, &3))

    Application.put_env(@app, {:format, encoding_name}, payload_format)
  end

  defp merge_format(_name, _k, nil, v), do: v
  defp merge_format(_name, _k, v, nil), do: v
  defp merge_format(_name, _k, v, v), do: v

  defp merge_format(name, k, v1, v2) do
    raise "Cannot register RTP payload format #{name} field #{k} to #{inspect(v2)}, " <>
            "already registered to #{inspect(v1)}."
  end
end
