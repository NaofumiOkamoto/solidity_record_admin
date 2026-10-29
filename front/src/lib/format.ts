// 商品の値を、CSV 出力（出品ページ）と同じ見え方に揃えるための変換

// "Earth_Wind & Fire" のように複数アーティストを "_" で連結している
export const formatArtist = (value: string | null) => (value ? value.replace(/_/g, ', ') : value);

// "VG+_EX-" のように幅のあるグレードを "_" で持っている。出品ページでは "~"
export const formatGrading = (value: string | null) => (value ? value.replace(/_/g, '~') : value);

// 一覧から詳細へ渡す location.state。一覧の URL（検索条件・ページ・ソート込み）を持たせ、
// 詳細の「一覧に戻る」でそこへ戻す
export type FromListState = { from?: string } | null;
