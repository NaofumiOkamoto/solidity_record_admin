
class GoogleApi::Spreadsheets
  require "google/apis/sheets_v4"

  def initialize
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.authorization = authorize
  end

  # 認証
  def authorize
    json_key = JSON.generate(
      private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDtjtDsf4yFsws0\nuaKzOyDtXI6V+tvBJX9ZetV7mtOstTwGQBfIDwLl6PZsQUmvZd8wh97Gcgkbe/tL\nUKzts6AaaiLUEhArUB0DummzAriDZhP28Jx6g7IRu+im/mcc37Qxc6vmRYQ+2ceG\nWZQ2T1ViU+fy57jGe2y99w1pYjAm/IeLTiRrOmneD4TPS4s4lXLZhPPopWOl9RLx\nHzdiSBUYccSMqoHvCvk0bUmuEw+J5zuAN/8Q9JnYwkZSZ/dx5UvWfy5ooVa8wEjI\ndcTVb+h4bdc4/ZdXLzQL64OT6ccAR/FdyN6akBX7yUVYtO4KKxMZUgKiaWfhqHDY\n6iGc6a5LAgMBAAECggEAGQmiZNVp/srIyufTNBzD8wB8WWZf3v2QFzg7uT6vl1Zg\nBdtKJmBz/RNkADOUC+kqxYyseDHwr8rjc3lZ9eZRYOIAMGXZpRcD19lqkTQfil8p\n34RV7xEOUDwuizCTtuwFAT6gcYaw0jGrNofJIpLopue9B1GmRz/Jou6fpT8fYBxY\nQfKOR3k86tEGl67drJ8+cAa/OfK+4reXGmyZkN82fYoPb3j0p30iDnb13G4I4wkD\nlwecr2dlI+LW76L64PSxTnkH32QGFrhr/+wp2gRM0jaRRlQaAL94/PbFvXuB+XLF\nD2o0npY6moPmsFFEKgODNOL2XlTdBHWz9Y73TnC7sQKBgQD6uw48TijCH0HhU3+a\nv3B75kiS4vSH71r2rDWceD9TaDQZAelLMzgMgcq7B54F8x3cwICBgrGwCQd5RPF6\nnAb9rEGcK2fw9n34QQSJgN27Lxp/Li9VfJNcR1zL9NZrRQNI5qT8Eqka0A7slLA8\nF6TxkkVNifv35CA+lmlYK+rsrQKBgQDyjOPcYErwT5Hd90hkkhDDfFJSnctpx5uy\nyj+D7jr8qdI0Ej04AIUpGWH7qPTgogH6TyCI7uQ8ldbpuJGyYU/N6Ws4CghyDS1J\nOjlAcDBgSh06QrGVaOWn0WofjwTAVPlalCy0UnoMdqxkON1El2/41+NZWx5Ftxyz\naU9QZNyt1wKBgFzdBRO+2wey7gKXm25kMzQggYatumXSd/1eoOiX/NRWht0wQQjS\nKpMvSzfkRVnsxoWpYq8VCdyqK3N13n5L5ab0ssQ1q2Sq1tMouZZ3/SfD9WtfXrap\n0iZeY/dCclv+jo3kpvyZqLo+jxh+pZtMIpI6W6KxVXplqq+jo9a9RWBtAoGAJW2K\nR9pwFe8hYjAjcql7fr7zcR46YmNT6l39OR2M6qpF7pUV70tdQP9SuGPVDcjSJ08I\nhTjf7V1t4XkCupT7nJm1WttpfDf+UftzFDd7r5AgPHpILvcV4TSWfLI0GH3EUK7m\nyxijDsNNTNXdhxUbSTn/Mi22WSmtex34CD7YMtcCgYEA2JXVgT7Y7oi+egRVnQD4\nK6VTaY8iC5i3QQyOIP2k+OFjqQ2Gv5slD6iY6zq+waQnyvy1fMyZuCSsQE+2xY4i\nUV1J/wfKPqzbfzo+tYGbQmm5GGYKzyX2oilVQ4tvbhXcx+PxDktbq9YnOKW7twyL\neQe8k8wDe4y0LwLAIxmF6fI=\n-----END PRIVATE KEY-----\n",
      client_email: "solidity-records@no-project-1567401128319.iam.gserviceaccount.com"
    )

    json_key_io = StringIO.new(json_key)

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: json_key_io,
      scope: ["https://www.googleapis.com/auth/spreadsheets"]
    )
    authorizer.fetch_access_token!
    authorizer
  end

  # 指定されたスプレッドシートIDとレンジ（範囲）から値を取得
  def get_values(spreadsheet_id, ragne)
    @service.get_spreadsheet_values(spreadsheet_id, ragne)
  end
end