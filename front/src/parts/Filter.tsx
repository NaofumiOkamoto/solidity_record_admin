import styled from 'styled-components';
import DatePicker from "react-datepicker"
import "react-datepicker/dist/react-datepicker.css"
import { Platforms } from '../page/Csv';

const FilterArea = styled.div`
  margin: 2rem 0;
  display: flex;
`
const Div = styled.div`
  margin-right:20px;
`
const DateArea = styled.div`
  display: flex;
  .react-datepicker-wrapper {
    width: 103px;
  }
`
const DateButton = styled.button`
  width: 100px;
`
const Text = styled.p`
  margin: 0;
  font-size: 80%;
`
const Select = styled.select`
padding: 1px 5px;
`
const QUANTITY = [
  {value: -1, label: '全て'},
  {value: 0, label: '0'},
  {value: 1, label: '1以上'},
]
const COUNTRY = [
  {value: 'all', label: '全て'},
  {value: 'except_japan', label: 'japan以外'},
  {value: 'japan', label: 'japanのみ'},
]

const formatDate = (dt) => {
  const y = dt.getFullYear();
  const m = ('00' + (dt.getMonth()+1)).slice(-2);
  const d = ('00' + dt.getDate()).slice(-2);
  return (y + '-' + m + '-' + d);
}

type Props = {
  platform: Platforms;
  registrationDate: Date;
  setRegistrationDate: (date) => void;
  country: string;
  setCountry: (string) => void;
  quantity: number;
  setQuantity: (num) => void;
}

export const Filter = ({
  platform,
  registrationDate,
  setRegistrationDate,
  country,
  setCountry,
  quantity,
  setQuantity,
}: Props) => {
  const handleChange = (date: Date) => {
    setRegistrationDate(date)
  }

  return (
    <FilterArea>
      <Div>
        <Text>在庫</Text>
        <Select value={quantity} onChange={e => setQuantity(e.target.value)}>
          {
            QUANTITY.map((v,i) => (
              <option key={i} value={v.value}>{v.label}</option>)
            )
          }
        </Select>
      </Div>
      <Div>
        <Text>国</Text>
        <Select value={country} onChange={e => setCountry(e.target.value)}>
          {
            COUNTRY.map((v,i) => (
              <option key={i} value={v.value}>{v.label}</option>)
            )
          }
        </Select>
      </Div>
      <Div>
        <Text>登録日</Text>
        <DateArea>
          <DatePicker
            selected={registrationDate}
            onChange={handleChange}
            customInput={
              <DateButton>
                {formatDate(registrationDate)}
              </DateButton>
            }
          />
          <Text>以降</Text>
        </DateArea>
      </Div>
    </FilterArea>
  )
}