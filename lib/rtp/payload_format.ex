defmodule Membrane.RTP.PayloadFormat do
  @moduledoc """
  This module contains utilities for resolving RTP default payload types,
  encoding names, clock rates and (de)payloaders.
  """

  require Membrane.RTP

  alias Membrane.RTP

  @app :membrane_rtp_format
  @format_env :__membrane_format
  @pt_env :__membrane_payload_type_mapping

  @payload_types_specs %{
    0 => %{encoding_name: :PCMU, clock_rate: 8_000},
    3 => %{encoding_name: :GSM, clock_rate: 8_000},
    4 => %{encoding_name: :G732, clock_rate: 8_000},
    5 => %{encoding_name: :DVI4, clock_rate: 8_000},
    6 => %{encoding_name: :DVI4, clock_rate: 16_000},
    7 => %{encoding_name: :LPC, clock_rate: 8_000},
    8 => %{encoding_name: :PCMA, clock_rate: 8_000},
    9 => %{encoding_name: :G722, clock_rate: 8_000},
    10 => %{encoding_name: :L16, clock_rate: 44_100},
    11 => %{encoding_name: :L16, clock_rate: 44_100},
    12 => %{encoding_name: :QCELP, clock_rate: 8_000},
    13 => %{encoding_name: :CN, clock_rate: 8_000},
    14 => %{encoding_name: :MPA, clock_rate: 90_000},
    15 => %{encoding_name: :G728, clock_rate: 8_000},
    16 => %{encoding_name: :DVI4, clock_rate: 11_025},
    17 => %{encoding_name: :DVI4, clock_rate: 22_050},
    18 => %{encoding_name: :G729, clock_rate: 8_000},
    25 => %{encoding_name: :CELB, clock_rate: 90_000},
    26 => %{encoding_name: :JPEG, clock_rate: 90_000},
    28 => %{encoding_name: :NV, clock_rate: 90_000},
    31 => %{encoding_name: :H261, clock_rate: 90_000},
    32 => %{encoding_name: :MPV, clock_rate: 90_000},
    33 => %{encoding_name: :MP2T, clock_rate: 90_000},
    34 => %{encoding_name: :H263, clock_rate: 90_000}
  }

  @enforce_keys [:encoding_name]
  defstruct @enforce_keys ++
              [
                payload_type: nil,
                payloader: nil,
                depayloader: nil,
                keyframe_detector: nil,
                frame_detector: nil
              ]

  @type t :: %__MODULE__{
          encoding_name: RTP.encoding_name(),
          payload_type: RTP.payload_type() | nil,
          payloader: module | nil,
          depayloader: module | nil,
          keyframe_detector: (binary() -> boolean()) | nil,
          frame_detector: (binary() -> boolean()) | nil
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
  @spec get_payload_type_mapping(RTP.payload_type()) :: %{
          optional(:encoding_name) => RTP.encoding_name(),
          optional(:clock_rate) => RTP.clock_rate()
        }
  def get_payload_type_mapping(payload_type) when RTP.is_payload_type_static(payload_type) do
    Map.fetch!(@payload_types_specs, payload_type)
  end

  def get_payload_type_mapping(payload_type) when RTP.is_payload_type_dynamic(payload_type) do
    get_env(@pt_env, payload_type, %{})
  end

  @doc """
  Registers default encoding name and clock rate for a dynamic payload_type
  """
  @spec register_payload_type_mapping(
          RTP.dynamic_payload_type(),
          RTP.encoding_name(),
          RTP.clock_rate()
        ) :: :ok | no_return()
  def register_payload_type_mapping(payload_type, encoding_name, clock_rate)
      when RTP.is_payload_type_dynamic(payload_type) do
    case fetch_env(@pt_env, payload_type) do
      {:ok, payload_format} ->
        raise "RTP payload type #{payload_type} already registered: #{inspect(payload_format)}"

      :error ->
        put_env(@pt_env, payload_type, %{encoding_name: encoding_name, clock_rate: clock_rate})
    end
  end

  @doc """
  Returns payload format registered for given encoding name.
  """
  @spec get(RTP.encoding_name()) :: t
  def get(encoding_name) do
    get_env(@format_env, encoding_name, %__MODULE__{encoding_name: encoding_name})
  end

  @doc """
  Registers payload format.

  Raises if some payload format field was already registered and set to different value.
  """
  @spec register(t) :: :ok | no_return
  def register(%__MODULE__{encoding_name: encoding_name} = payload_format) do
    payload_format =
      get_env(@format_env, encoding_name, %{})
      |> Map.merge(payload_format, &merge_format(encoding_name, &1, &2, &3))

    put_env(@format_env, encoding_name, payload_format)
  end

  @doc """
  Quality of life function that makes best effort resolution of `PayloadFormat`, payload type and clock rate based
  on provided arguments. Prefers provided values over registered defaults.
  """
  @spec resolve(
          encoding_name: RTP.encoding_name() | nil,
          payload_type: RTP.payload_type() | nil,
          clock_rate: RTP.clock_rate() | nil
        ) :: {payload_format :: t() | nil, RTP.payload_type() | nil, RTP.clock_rate() | nil}
  def resolve(args) do
    encoding_name = resolve_encoding_name(args[:encoding_name], args[:payload_type])
    payload_format = resolve_payload_format(encoding_name, args[:payload_type])
    payload_type = resolve_payload_type(args[:payload_type], payload_format)
    clock_rate = resolve_clock_rate(args[:clock_rate], payload_type)

    {payload_format, payload_type, clock_rate}
  end

  @spec resolve_encoding_name(RTP.encoding_name() | nil, RTP.payload_type() | nil) ::
          RTP.encoding_name() | nil
  defp resolve_encoding_name(encoding_name, payload_type) do
    case {encoding_name, payload_type} do
      {nil, nil} ->
        nil

      {nil, payload_type} ->
        case get_payload_type_mapping(payload_type) do
          %{encoding_name: registered_encoding_name} -> registered_encoding_name
          _payload_type_mapping_not_registered -> nil
        end

      {encoding_name, _payload_type} ->
        encoding_name
    end
  end

  @spec resolve_payload_format(RTP.encoding_name() | nil, RTP.payload_type() | nil) :: t() | nil
  defp resolve_payload_format(encoding_name, payload_type) do
    case encoding_name do
      nil ->
        nil

      encoding_name ->
        registered_payload_format = get(encoding_name)

        case payload_type do
          nil -> registered_payload_format
          payload_type -> %{registered_payload_format | payload_type: payload_type}
        end
    end
  end

  @spec resolve_payload_type(RTP.payload_type() | nil, t() | nil) :: RTP.payload_type() | nil
  defp resolve_payload_type(payload_type, payload_format) do
    case {payload_type, payload_format} do
      {nil, nil} -> nil
      {nil, payload_format} -> payload_format.payload_type
      {payload_type, _payload_format} -> payload_type
    end
  end

  @spec resolve_clock_rate(RTP.clock_rate() | nil, RTP.payload_type() | nil) ::
          RTP.clock_rate() | nil
  defp resolve_clock_rate(clock_rate, payload_type) do
    case {clock_rate, payload_type} do
      {nil, nil} ->
        nil

      {nil, payload_type} ->
        case get_payload_type_mapping(payload_type) do
          %{clock_rate: clock_rate} -> clock_rate
          _payload_type_mapping_not_registered -> nil
        end

      {clock_rate, _payload_type} ->
        clock_rate
    end
  end

  defp merge_format(_name, _k, nil, v), do: v
  defp merge_format(_name, _k, v, nil), do: v
  defp merge_format(_name, _k, v, v), do: v

  defp merge_format(name, k, v1, v2) do
    raise "Cannot register RTP payload format #{name} field #{k} to #{inspect(v2)}, " <>
            "already registered to #{inspect(v1)}."
  end

  defp put_env(env_key, key, value) do
    env = Application.get_env(@app, env_key, %{})
    Application.put_env(@app, env_key, Map.put(env, key, value))
  end

  defp fetch_env(env_key, key) do
    Application.get_env(@app, env_key, %{}) |> Map.fetch(key)
  end

  defp get_env(env_key, key, default) do
    case fetch_env(env_key, key) do
      {:ok, value} -> value
      :error -> default
    end
  end
end
