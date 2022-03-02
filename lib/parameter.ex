defmodule Static.Parameter do
  use AbnfParsec,
    abnf_file: "lib/parameter.abnf",
    parse: :params,
    untag: ["params", "action", "word"],
    ignore: [
      "content-path-cmd",
      "output-path-cmd",
      "space"
    ]

  alias __MODULE__

  @type t :: %Parameter{
          content_path: String.t(),
          output_path: String.t()
        }

  defstruct content_path: nil,
            output_path: nil

  def get_params(nil), do: []
  def get_params([]), do: []

  def get_params(raw_params) do
    raw_params
    |> Enum.join(" ")
    |> parse()
    |> case do
      {:ok, [parsed_params], _rest, _, _, _} ->
        parsed_params
        |> Enum.reduce(%Parameter{}, fn found_param, acc ->
          case found_param do
            [content_path: [term: [content_path]]] ->
              %Parameter{acc | content_path: content_path |> List.to_string()}

            [output_path: [term: [output_path]]] ->
              %Parameter{acc | output_path: output_path |> List.to_string()}

            _ ->
              acc
          end
        end)

      _ ->
        %Parameter{}
    end
  end
end