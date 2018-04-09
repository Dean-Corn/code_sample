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
        {:error, "Failed to create comment \"#{comment}\", POST returned #{status_code}: #{Poison.decode!(body)}"}
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

  @doc """
  Deletes a comment
  """
  @spec delete_comment(String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def delete_comment(comment_id, token) do
    case HTTPoison.delete! "https://api.box.com/2.0/comments/#{comment_id}", %{Authorization: "Bearer #{token}"} do
      %{status_code: 204} ->
        {:ok, "Successfully deleted Comment ID #{comment_id}"}
      %{status_code: 401} ->
        {:auth_failure, "Failed to delete comment.  Authorization token is invalid"}
      %{status_code: code, body: body} ->
        {:error, "Failed to delete Comment ID #{comment_id}.  DELETE received #{code}: #{body}"}
    end
  end

  @doc """
  Deletes a comment
  Works the exact same as delete_comment, except it raises an exception if the delete fails
  """
  def delete_comment!(comment_id, token) do
    case delete_comment(comment_id, token) do
      {:ok, _} ->
        :ok
      {_, error} ->
        raise error
    end
  end

  @doc """
  Updates a comment
  """
  @spec update_comment(String.t, String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def update_comment(comment, comment_id, token) do
    case HTTPoison.put! "https://api.box.com/2.0/comments/#{comment_id}",Poison.encode!(%{message: "#{comment}"}), %{Authorization: "Bearer #{token}"} do
      %{status_code: 200, body: body} ->
        {:ok, "Successfully updated Comment ID #{comment_id}"}
      %{status_code: 401} ->
        {:auth_failure, "Failed to update comment.  Authorization token is invalid"}
      %{status_code: status_code, body: body} ->
        {:error, "Failed to update Comment ID #{comment_id}, PUT returned #{status_code}: #{Poison.decode!(body)}"}
    end
  end

  @doc """
  Updates a comment
  Works the exact same as update_comment, except it raises an exception if the delete fails
  """
  def update_comment!(comment, comment_id, token) do
    case update_comment(comment, comment_id, token) do
      {:ok, _} ->
        :ok
      {_, error} ->
        raise error
    end
  end

  #Extra Functions

  @doc """
  Gets a comment
  """
  @spec get_comment(String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def get_comment(comment_id, token) do
    case HTTPoison.get! "https://api.box.com/2.0/comments/#{comment_id}", %{Authorization: "Bearer #{token}"} do
      %{status_code: 200, body: body} ->
        message = body
                  |> Poison.decode!
                  |> Map.get("message")
        {:ok, message}
      %{status_code: 401} ->
        {:auth_failure, "Failed to get comment.  Authorization token is invalid"}
      %{status_code: code, body: body} ->
        raise "Failed to get Comment ID #{comment_id}.  Received #{code}: #{body}"
    end
  end

  @doc """
  Gets a comment
  Works the exact same as get_comment, except it raises an exception if the delete fails
  """
  def get_comment!(comment_id, token) do
    case get_comment(comment_id, token) do
      {:ok, message} ->
        message
      {_, error} ->
        raise error
    end
  end

end
