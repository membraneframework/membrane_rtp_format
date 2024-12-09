defmodule Membrane.RTP.ResolveTest do
  use ExUnit.Case
  alias Membrane.RTP.PayloadFormat

  defmodule TestH263Depayloader do
  end

  defmodule TestCzumpiDepayloader do
  end

  @h263_payload_format %PayloadFormat{
    encoding_name: :H263,
    payload_type: 34,
    depayloader: TestH263Depayloader
  }

  @czumpi_payload_format %PayloadFormat{
    encoding_name: :Czumpi,
    payload_type: 126,
    depayloader: TestCzumpiDepayloader
  }

  setup_all do
    PayloadFormat.register(@h263_payload_format)
    PayloadFormat.register(@czumpi_payload_format)
    PayloadFormat.register_payload_type_mapping(126, :Czumpi, 2007)
  end

  describe "Resolve resolves correctly" do
    test "for no arguments" do
      assert %{payload_format: nil, payload_type: nil, clock_rate: nil} =
               PayloadFormat.resolve([])
    end

    test "for registered encoding names" do
      assert %{payload_format: @czumpi_payload_format, payload_type: 126, clock_rate: 2007} =
               PayloadFormat.resolve(encoding_name: :Czumpi)

      assert %{payload_format: @h263_payload_format, payload_type: 34, clock_rate: 90_000} =
               PayloadFormat.resolve(encoding_name: :H263)
    end

    test "for unregistered encoding names" do
      assert %{
               payload_format: %PayloadFormat{encoding_name: :H2137, payload_type: nil},
               payload_type: nil,
               clock_rate: nil
             } = PayloadFormat.resolve(encoding_name: :H2137)

      assert %{
               payload_format: %PayloadFormat{encoding_name: :H2137, payload_type: 111},
               payload_type: 111,
               clock_rate: 30_000
             } =
               PayloadFormat.resolve(encoding_name: :H2137, payload_type: 111, clock_rate: 30_000)
    end

    test "when encoding name wasn't provided, but payload type was" do
      assert %{
               payload_format: %PayloadFormat{encoding_name: :H263, payload_type: 34},
               payload_type: 34,
               clock_rate: 90_000
             } = PayloadFormat.resolve(payload_type: 34)

      assert %{payload_format: @czumpi_payload_format, payload_type: 126, clock_rate: 2007} =
               PayloadFormat.resolve(payload_type: 126)
    end

    test "for unregistered payload types" do
      assert %{payload_format: nil, payload_type: 112, clock_rate: nil} =
               PayloadFormat.resolve(payload_type: 112)

      assert %{
               payload_format: %PayloadFormat{encoding_name: :Szymon, payload_type: 112},
               payload_type: 112,
               clock_rate: nil
             } = PayloadFormat.resolve(encoding_name: :Szymon, payload_type: 112)
    end

    test "for conflicting payload types" do
      updated_czumpi_payload_format = %{@czumpi_payload_format | payload_type: 120}

      assert %{payload_format: ^updated_czumpi_payload_format, payload_type: 120, clock_rate: nil} =
               PayloadFormat.resolve(encoding_name: :Czumpi, payload_type: 120)
    end

    test "for conflicting encoding names" do
      assert %{
               payload_format: %PayloadFormat{encoding_name: :Szymon, payload_type: 126},
               payload_type: 126,
               clock_rate: 2007
             } = PayloadFormat.resolve(encoding_name: :Szymon, payload_type: 126)
    end
  end
end
