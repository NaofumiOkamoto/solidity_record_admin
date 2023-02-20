import { useState } from 'react';
import axios from 'axios';
import styled from 'styled-components';
import { Filter } from '../parts/Filter';

export type Platforms = 'discogs' | 'mercari'

const platforms: Array<Platforms> = [
  'discogs',
  'mercari',
]
const Container = styled.div`
  margin: 2rem;
`
const Button = styled.button`
  background-color: #FFFFFF;
  border: 1px solid rgb(209,213,219);
  border-radius: .5rem;
  box-sizing: border-box;
  color: #111827;
  font-family: "Inter var",ui-sans-serif,system-ui,-apple-system,system-ui,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
  font-size: .875rem;
  font-weight: 600;
  line-height: 1.25rem;
  padding: .75rem 1rem;
  text-align: center;
  text-decoration: none #D1D5DB solid;
  text-decoration-thickness: auto;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  cursor: pointer;
  user-select: none;
  -webkit-user-select: none;
  touch-action: manipulation;
`
const Hr = styled.hr`
  width: 90%;
  background-color: #dddddd;
  height: 1px;
  border: none;
`

export type FilterState = {
  discogs: {
    date: Date,
    country: string, // 全ての国
    quantity: number,
  },
  mercari: {
    date: Date,
    country: string, // 日本以外
    quantity: number,
  },
}

export const Csv = () => {

  const filterData = {
    discogs: {
      date: new Date(),
      // date: new Date(2022, 0, 1),
      country: 'all', // 全ての国
      quantity: 1, // 在庫1以上
    },
    mercari: {
      date: new Date(),
      // date: new Date(2022, 0, 1),
      country: 'except_japan', // 日本以外
      quantity: 1, // 在庫1以上
    },
  }
  const [filterState, setFilterState] = useState(filterData)
  let testParams = '&'
  for ( let key in filterState[platforms[0]] ) {
    testParams = `${testParams}${key}=${String(filterState[platforms[0]][key])}&`
  }

  const getApi = (platform) => {
    const envUrl = process.env.REACT_APP_API_URL
    const envPort = process.env.REACT_APP_API_PORT
    const url = `${envUrl}:${envPort}/csv/new.csv`
    const platformParams = `?platform=${platform}`
    axios.get(`${url}${platformParams}${testParams}`, { responseType: "blob", }).then((res) => {
      const url = URL.createObjectURL( new Blob([res.data], { type: "text/csv" }) );
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", `${platform}.csv`);
      document.body.appendChild(link);
      link.click();
      URL.revokeObjectURL(url);
      link.parentNode?.removeChild(link);
    })
  }

  return (
    <>
      {platforms.map(platform => {
        return (
          <>
            <Container>
              <h2>{platform}</h2>
              <Filter
                platform={platform}
                filterState={filterState}
                setFilterState={setFilterState}
              />
              <Button
                onClick={() => getApi(platform)}
              >
                csvを出力
              </Button>
            </Container>
            <Hr />
          </>
        )
      })}
    </>
  )
}