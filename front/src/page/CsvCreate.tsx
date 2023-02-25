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
      country: 'all', // 全ての国
      quantity: 1, // 在庫1以上
    },
    mercari: {
      date: new Date(),
      country: 'except_japan', // 日本以外
      quantity: 1, // 在庫1以上
    },
  }
  const [filterState, setFilterState] = useState(filterData)

  const getApi = async (platform) => {
    let filterParams = '&'
    for ( let key in filterState[platform] ) {
      filterParams = `${filterParams}${key}=${String(filterState[platform][key])}&`
    }
    const envUrl = process.env.REACT_APP_API_URL
    const envPort = process.env.REACT_APP_API_PORT
    const url = `${envUrl}:${envPort}/csv/new.csv`
    const platformParams = `?platform=${platform}`
    try {
      const res = await axios.get(`${url}${platformParams}${filterParams}`, { responseType: "blob", })
      const downloadUrl = URL.createObjectURL( new Blob([res.data], { type: "text/csv" }) );
      const link = document.createElement("a");
      link.href = downloadUrl;
      link.setAttribute("download", `${platform}.csv`);
      document.body.appendChild(link);
      link.click();
      URL.revokeObjectURL(downloadUrl);
      link.parentNode?.removeChild(link);
    } catch(e) {
      if (e.code === "ERR_BAD_REQUEST") {
        alert('!!!!!スプレットシートの項目順か項目名が正しくなーい!!!!!\nのでcsvを作成できませんでした。')
      } else {
        alert('なにかしらおかしいことがおきました。岡本まで')
      }
    }
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