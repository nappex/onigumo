defmodule Onigumo do
  @moduledoc """
  Web scraper
  """
  @output_path "body.html"

  def main() do
    HTTPoison.start()
    http = http_client()

    Application.get_env(:onigumo, :input_path)
    |> load_urls()
    |> Enum.map(&download(&1, http, @output_path))
  end

  def download(url, http, path) do
    %HTTPoison.Response{
      status_code: 200,
      body: body
    } = http.get!(url)

    File.write!(path, body)
  end

  def load_urls(path) do
    File.stream!(path, [:read], :line)
    |> Enum.map(&String.trim_trailing/1)
  end

  defp http_client() do
    Application.get_env(:onigumo, :http_client)
  end
end
