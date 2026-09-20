import styled from 'styled-components';

// 画面をまたいで使う見た目の部品。既存の CsvCreate.tsx のボタンに合わせている。

export const Button = styled.button`
  background-color: #fff;
  border: solid 2px #b3b3b3;
  padding: 10px 30px;
  font-weight: bold;
  border-radius: 2px;
  &:hover:not(:disabled) {
    cursor: pointer;
    background-color: #ebebeb;
  }
  &:disabled {
    opacity: 0.4;
  }
`;

export const PrimaryButton = styled(Button)`
  background-color: #3b5d8f;
  border-color: #3b5d8f;
  color: #fff;
  &:hover:not(:disabled) {
    background-color: #33517c;
  }
`;

export const Input = styled.input`
  width: 100%;
  box-sizing: border-box;
  padding: 6px 8px;
  border: solid 1px #b3b3b3;
  border-radius: 2px;
  font-size: 14px;
`;

export const Select = styled.select`
  width: 100%;
  box-sizing: border-box;
  padding: 6px 8px;
  border: solid 1px #b3b3b3;
  border-radius: 2px;
  background-color: #fff;
  font-size: 14px;
`;

export const FieldLabel = styled.label`
  display: block;
  margin-bottom: 4px;
  font-size: 12px;
  color: #555;
`;
