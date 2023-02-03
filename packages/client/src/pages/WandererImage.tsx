import { BigNumber } from '@ethersproject/bignumber'
import { useEffect, useState } from 'react'
import { useWTokens } from '../hooks/useWTokens'

export default function WandererImage({ id }: { id: BigNumber }) {
    const [img, setImg] = useState('')
    const { getJson } = useWTokens()

    useEffect(() => {
        if (!getJson) return
        (async () => {
            const json = await getJson(id)
            setImg(json.image)
        })()
    }, [id, getJson, setImg])

    return <object data={img} className="w-64 h-64" />
}