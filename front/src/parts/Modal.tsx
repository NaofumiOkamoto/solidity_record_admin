import { ReactNode, useEffect, useRef } from 'react';
import styled from 'styled-components';

// 編集フォームで使うモーダルの枠（ジャンル選択・説明文の定型文）。
// 「キャンセル」・Esc・枠外クリックで onClose を呼ぶ。中身は開いている間だけ描画するので、
// 中身の state は開くたびに作り直される（前回キャンセルした途中の状態は持ち越さない）。

// 枠外クリックを拾うため、dialog 自体には余白を付けず中身に付ける
const Dialog = styled.dialog`
  width: min(720px, calc(100vw - 32px));
  max-height: calc(100vh - 64px);
  padding: 0;
  border: none;
  border-radius: 6px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.25);
  &::backdrop {
    background-color: rgba(0, 0, 0, 0.4);
  }
`;
const Body = styled.div`
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 64px);
`;
export const ModalHeader = styled.div`
  padding: 16px 20px 12px;
  border-bottom: solid 1px #ddd;
`;
export const ModalTitle = styled.h2`
  margin: 0;
  font-size: 16px;
`;
// 上の余白は付けない。sticky の見出し（ModalGroupTitle）は余白の内側に止まるため、
// 余白があるとその隙間をスクロールした行が通って透けて見える。上の空きは ModalGroup の margin でとる
export const ModalList = styled.div`
  flex: 1;
  overflow-y: auto;
  padding: 0 20px 16px;
`;
export const ModalGroup = styled.section`
  margin: 8px 0 0;
`;
// 分類の見出し。一覧（ModalList）をスクロールしても、今見ている分類の見出しが上に残る。
// fieldset の legend は sticky にできないブラウザがあるため、ふつうの見出しにしている。
// 一覧の左右の余白（20px）まで背景を広げ、下の行が透けないようにする
export const ModalGroupTitle = styled.h3`
  position: sticky;
  top: 0;
  z-index: 1;
  margin: 0 -20px 4px;
  padding: 4px 20px;
  background-color: #fff;
  border-bottom: solid 1px #eee;
  font-size: 13px;
  font-weight: bold;
  color: #555;
`;
export const ModalFooter = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 20px;
  border-top: solid 1px #ddd;
`;

type Props = {
  open: boolean;
  onClose: () => void;
  children: ReactNode;
};

export const Modal = ({ open, onClose, children }: Props) => {
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (open && !dialog.open) dialog.showModal();
    else if (!open && dialog.open) dialog.close();
  }, [open]);

  return (
    <Dialog
      ref={dialogRef}
      // Esc で閉じたとき
      onCancel={(e) => {
        e.preventDefault();
        onClose();
      }}
      onClick={(e) => e.target === dialogRef.current && onClose()}
    >
      {open && <Body>{children}</Body>}
    </Dialog>
  );
};
