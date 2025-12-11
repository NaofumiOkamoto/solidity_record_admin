import { useState } from 'react';
import ReactLoading from 'react-loading';
import axios from 'axios';
import styled from 'styled-components';
import { Filter } from '../parts/Filter';
import { DeleteFilter } from '../parts/DeleteFilter';
import { ImgParams } from '../parts/ImgParams';


export type Platforms = 'discogs' | 'mercari' | 'shopify' | 'ebay' | 'yahoo' | 'yahoo_auction'

const platforms: Array<Platforms> = [
  'discogs',
  'mercari',
  'shopify',
  'yahoo',
  'yahoo_auction',
  'ebay',
]
const Container = styled.div`
  margin: 2rem;
`
const Button = styled.button`
margin-top: 30px;
  background-color: #fff;
  border: solid 2px #b3b3b3;
  padding: 10px 30px;
  font-weight: bold;
  &:hover {
    cursor: pointer;
    background-color: #ebebeb;
  }
`
const Hr = styled.hr`
  width: 98%;
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

const Header = styled.div`
  width: 100%;
  border-bottom: solid 2px #ebebeb;
`

const SelectArea = styled.div`
  display: flex;
  justify-content: space-between;
  margin: 30px 25px -2px 20px;
`
const Tab = styled.button`
  background-color: ${p => p.theme.selectPlatform ? "#fff" : '#ebebeb'};
  width: 100%;
  border: solid 3px ${p => p.theme.selectPlatform ? "#ebebeb" : '#fff'};
  border-bottom: solid 1px ${p => p.theme.selectPlatform ? "#fff" : '#ebebeb'};
  padding: 15px;
  font-weight: bold;
  border-radius: 2px 2px 0 0;
`
  // border-top: solid 3px ${p => p.theme.selectPlatform ? "#b0e0e9" : '#fff'};

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
  yahoo: {
    date: Date,
    country: string, // 全ての国
    quantity: number,
  },
  yahoo_auction: {
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
      country: 'except_japan', // 日本以外
      quantity: 1, // 在庫1以上
    },
    yahoo: {
      date: new Date(),
      country: 'except_japan', // 全ての国
      quantity: 1, // 在庫1以上
    },
    yahoo_auction: {
      date: new Date(),
      country: 'except_japan', // 全ての国
      quantity: 1, // 在庫1以上
    },
  }
  const [filterState, setFilterState] = useState(filterData)
  const [imgParams, setImgParams] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [selectPlatform, setSelectPlatform] = useState<Platforms>('discogs')
  const imgParameter = imgParams ? `&imgParams=${imgParams}` : '';
  const envUrl = process.env.REACT_APP_API_URL
  const envPort = process.env.REACT_APP_API_PORT

  const getApi = async (platform, path) => {
    setIsLoading(true);
    let filterParams = '&'
    for ( let key in filterState[platform] ) {
      filterParams = `${filterParams}${key}=${String(filterState[platform][key])}&`
    }
    const url = `${envUrl}:${envPort}/${path}/new.csv`
    const platformParams = `?platform=${platform}`
    try {
      const res = await axios.get(`${url}${platformParams}${filterParams}${imgParameter}`, { responseType: "blob", })
      setIsLoading(false);
      const downloadUrl = URL.createObjectURL( new Blob([res.data], { type: "text/csv" }) );
      const link = document.createElement("a");
      link.href = downloadUrl;
      const csvName = path === 'csv' ? `${platform}_upload.csv` : `${platform}_delete.csv`;
      link.setAttribute("download", csvName);
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
      <Header>
        <SelectArea>
          {platforms.map(platform =>
            <Tab
              onClick={() => setSelectPlatform(platform)}
              theme={{selectPlatform: selectPlatform === platform}}
            >
              {platform}
            </Tab>
          )}
        </SelectArea>
      </Header>
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
        <div key={selectPlatform}>
          <Container>
            <h2>{selectPlatform}</h2>
            <Filter
              platform={selectPlatform}
              filterState={filterState}
              setFilterState={setFilterState}
            />
            {selectPlatform === 'shopify' &&
            <ImgParams
              imgParams={imgParams}
              setImgParams={setImgParams}
            />
            }
            <Button
              onClick={() => getApi(selectPlatform, 'csv')}
            >
              export upload csv
            </Button>
          </Container>
          <Hr />
          {(selectPlatform === 'discogs' ||
            selectPlatform === 'yahoo' ||
            selectPlatform === 'yahoo_auction' ||
            selectPlatform === 'shopify' ||
            selectPlatform === 'ebay' ||
            selectPlatform === 'mercari') &&
            <Container>
              <DeleteFilter
                platform={selectPlatform}
                filterState={filterState}
                setFilterState={setFilterState}
              />
              <Button
                onClick={() => getApi(selectPlatform, 'delete_product_csv')}
              >
                export delete csv
              </Button>
            </Container>
          }
        </div>
      }
    </>
  )
}