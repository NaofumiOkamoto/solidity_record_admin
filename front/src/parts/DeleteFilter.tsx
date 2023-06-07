import styled from 'styled-components';
import DatePicker from "react-datepicker"
import "react-datepicker/dist/react-datepicker.css"
import { Platforms, FilterState } from '../page/CsvCreate';

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
  background-color: #fff;
  border: solid 1px #b3b3b3;
  padding: 6px 6px;
`
const Text = styled.p`
  margin: 0;
  font-size: 80%;
`

const formatDate = (dt) => {
  const y = dt.getFullYear();
  const m = ('00' + (dt.getMonth()+1)).slice(-2);
  const d = ('00' + dt.getDate()).slice(-2);
  return (y + '-' + m + '-' + d);
}

type Props = {
  platform: Platforms;
  filterState: FilterState;
  setFilterState: (v) => void;
}

export const DeleteFilter = ({
  platform,
  filterState,
  setFilterState,
}: Props) => {
  const handleChange = (date: Date) => {
    setFilterState({...filterState, [platform]: {...filterState[platform], date: date}})
  }

  return (
    <FilterArea>
      <Div>
        <Text>売却日</Text>
        <DateArea>
          <DatePicker
            selected={filterState[platform]['date']}
            onChange={handleChange}
            customInput={
              <DateButton>
                {formatDate(filterState[platform]['date'])}
              </DateButton>
            }
          />
          <Text>以降</Text>
        </DateArea>
      </Div>
    </FilterArea>
  )
}