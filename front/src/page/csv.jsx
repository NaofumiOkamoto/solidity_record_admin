import axios from 'axios';

export const Csv = () => {

  const getApi = (platform) => {
    const envUrl = process.env.REACT_APP_API_URL
    const url = `${envUrl}/csv/new.csv`
    const params = `?platform=${platform}`
    axios.get(`${url}${params}`, { responseType: "blob", }).then((res) => {
      console.log('res', res.data)
      const url = URL.createObjectURL( new Blob([res.data], { type: "text/csv" }) );
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", `${platform}.csv`);
      document.body.appendChild(link);
      link.click();
      URL.revokeObjectURL(url);
      link.parentNode.removeChild(link);
    })
  }

  const platforms = [
    'discogs',
    'shopify',
  ]

  return (
    <>
      {platforms.map((platform) => {
        {/* <label for="country-select">国を選択</label>
        <select name="countries" id="country-select">
            <option value="">国</option>
            <option value="dog">japan</option>
            <option value="cat">海外</option>
        </select> */}
        return (
          <div>
            <h3>{platform}</h3>
            <button
              onClick={() => getApi(platform)}
            >
              csvを出力
            </button>
          </div>
        )
      })}
    </>
  )
}