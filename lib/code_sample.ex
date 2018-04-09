defmodule CodeSample do
  @spec get_comments!(String.t, String.t) :: integer
  def get_comments!(file_id, token) do
    case HTTPoison.get! "https://api.box.com/2.0/files/#{file_id}/comments", %{Authorization: "Bearer #{token}"} do
      %{status_code: 200, body: body} ->
        body
        |> Poison.decode!
        |> Map.get("entries")
      %{status_code: code, body: body} ->
        raise "Failed to get comments.  Received #{code}: #{body}"
    end
  end
  
  #Required Functions

  @doc """
  Creates a comment on the given file.
  """
  @spec create_comment(String.t, String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def create_comment(comment, file_id, token) do
    case HTTPoison.post("https://api.box.com/2.0/comments", Poison.encode!(%{item: %{type: "file", id: "#{file_id}"}, message: "#{comment}"}), %{Authorization: "Bearer #{token}"}) do
      {:ok, %{status_code: 201, body: body}} ->
        comment_id = body
                      |> Poison.decode!
                      |> Map.get("id")
        {:ok, comment_id}
      {_, %{status_code: 401}} ->
        {:auth_failure, "Failed to create comment.  Authorization token is invalid"}
      {_, %{status_code: status_code, body: body}} ->
        {:error, "Failed to create #{comment} comment, POST returned #{status_code}: #{Poison.decode!(body)}"}
      {_, %{reason: reason}} ->
        {:error, "Failed to create #{comment}. Received HTTPoison error #{reason}"}
    end
  end


  @doc """
  Creates a comment on the given file.
  Works the exact same as create_comment, except it raises an exception if the post fails
  """
  def create_comment!(comment, file_id, token) do
    case create_comment(comment, file_id, token) do
      {:ok, comment_id} ->
        comment_id
      {_, error} ->
        raise error
    end
  end

end
