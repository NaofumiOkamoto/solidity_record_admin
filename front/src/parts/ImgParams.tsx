import styled from 'styled-components';

const Text = styled.p`
  margin: 0;
  font-size: 80%;
`
const Input = styled.input`
  margin-bottom: 1rem;
  width: 200px;
  height: 20px;
`

type Props = {
  imgParams: string;
  setImgParams: (params: string) => void;
}

export const ImgParams = ({
  imgParams,
  setImgParams,
}: Props) => {

  return (
    <div>
      <Text>画像パラメータ</Text>
      <Input
        value={imgParams}
        onChange={(e) => setImgParams(e.target.value)}
      />
    </div>
  )
}