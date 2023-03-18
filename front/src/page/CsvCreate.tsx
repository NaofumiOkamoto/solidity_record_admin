import { useState } from 'react';
import ReactLoading from 'react-loading';
import axios from 'axios';
import styled from 'styled-components';
import { Filter } from '../parts/Filter';
import { ImgParams } from '../parts/ImgParams';


export type Platforms = 'discogs' | 'mercari' | 'shopify' | 'ebay'

const platforms: Array<Platforms> = [
  'discogs',
  'mercari',
  'shopify',
  'ebay',
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
const Loading = styled.div`
  text-align: center;
  margin-top: 100px;
`
const Div = styled.div`
  width: 100px;
  margin: 0 auto;
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
  shopify: {
    date: Date,
    country: string, // 全ての国
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
    shopify: {
      date: new Date(),
      country: 'all', // 全ての国
      quantity: -1, // 全て
    },
    ebay: {
      date: new Date(),
      country: 'all', // 全ての国
      quantity: 1, // 在庫1以上
    },
  }
  const [filterState, setFilterState] = useState(filterData)
  const [imgParams, setImgParams] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const getApi = async (platform) => {
    setIsLoading(true);
    let filterParams = '&'
    for ( let key in filterState[platform] ) {
      filterParams = `${filterParams}${key}=${String(filterState[platform][key])}&`
    }
    const imgParameter = imgParams ? `&imgParams=${imgParams}` : '';
    const envUrl = process.env.REACT_APP_API_URL
    const envPort = process.env.REACT_APP_API_PORT
    const url = `${envUrl}:${envPort}/csv/new.csv`
    const platformParams = `?platform=${platform}`
    try {
      const res = await axios.get(`${url}${platformParams}${filterParams}${imgParameter}`, { responseType: "blob", })
      setIsLoading(false);
      const downloadUrl = URL.createObjectURL( new Blob([res.data], { type: "text/csv" }) );
      const link = document.createElement("a");
      link.href = downloadUrl;
      link.setAttribute("download", `${platform}.csv`);
      document.body.appendChild(link);
      link.click();
      URL.revokeObjectURL(downloadUrl);
      link.parentNode?.removeChild(link);
    } catch(e) {
      setIsLoading(false);
      console.log('e', e)
      if (e.code === "ERR_BAD_REQUEST") {
        alert('!!!!!スプレットシートの項目順か項目名が正しくなーい!!!!!\nのでcsvを作成できませんでした。')
      } else {
        alert('なにかしらおかしいことがおきました。岡本まで')
      }
    }
  }

  return (
    <>
    {isLoading ?
      <Loading>
        <Div>
          <ReactLoading
            type="spinningBubbles"
            color="#b2cbf3"
            height="100px"
            width="100px"
            className="mx-auto"
          />
        </Div>
        <p>csvを作成中です....</p>
      </Loading>
      :
      platforms.map(platform => {
        return (
          <div key={platform}>
            <Container>
              <h2>{platform}</h2>
              <Filter
                platform={platform}
                filterState={filterState}
                setFilterState={setFilterState}
              />
              {platform === 'shopify' &&
              <ImgParams
                imgParams={imgParams}
                setImgParams={setImgParams}
              />
              }
              <Button
                onClick={() => getApi(platform)}
              >
                csvを出力
              </Button>
            </Container>
            <Hr />
          </div>
        )
      })
    }
    </>
  )
}