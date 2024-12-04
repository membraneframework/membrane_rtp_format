defmodule Membrane.RTP.ResolveTest do
  alias Membrane.RTP.PayloadFormat
  use ExUnit.Case

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
      assert {nil, nil, nil} = PayloadFormat.resolve([])
    end

    test "for registered encoding names" do
      assert {@czumpi_payload_format, 126, 2007} = PayloadFormat.resolve(encoding_name: :Czumpi)
      assert {@h263_payload_format, 34, 90_000} = PayloadFormat.resolve(encoding_name: :H263)
    end

    test "for unregistered encoding names" do
      assert {%PayloadFormat{encoding_name: :H2137, payload_type: nil}, nil, nil} =
               PayloadFormat.resolve(encoding_name: :H2137)

      assert {%PayloadFormat{encoding_name: :H2137, payload_type: 111}, 111, 30_000} =
               PayloadFormat.resolve(encoding_name: :H2137, payload_type: 111, clock_rate: 30_000)
    end

    test "when encoding name wasn't provided, but payload type was" do
      assert {%PayloadFormat{encoding_name: :H263, payload_type: 34}, 34, 90_000} =
               PayloadFormat.resolve(payload_type: 34)

      assert {@czumpi_payload_format, 126, 2007} = PayloadFormat.resolve(payload_type: 126)
    end

    test "for unregistered payload types" do
      assert {nil, 112, nil} = PayloadFormat.resolve(payload_type: 112)

      assert {%PayloadFormat{encoding_name: :Szymon, payload_type: 112}, 112, nil} =
               PayloadFormat.resolve(encoding_name: :Szymon, payload_type: 112)
    end

    test "for conflicting payload types" do
      updated_czumpi_payload_format = %{@czumpi_payload_format | payload_type: 120}

      assert {^updated_czumpi_payload_format, 120, nil} =
               PayloadFormat.resolve(encoding_name: :Czumpi, payload_type: 120)
    end

    test "for conflicting encoding names" do
      assert {%PayloadFormat{encoding_name: :Szymon, payload_type: 126}, 126, 2007} =
               PayloadFormat.resolve(encoding_name: :Szymon, payload_type: 126)
    end
  end
end
