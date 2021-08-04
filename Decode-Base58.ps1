function Decode-Base58
{
    [cmdletbinding()]
    Param(
        [string]$base58_encoded_string,
        [switch]$output_plaintext,
        [switch]$output_hexidecimal
    )
    $leading_ones = [regex]::New("^(1*)").Match($base58_encoded_string).Groups[1].Length
    $BASE58 = [System.Text.Encoding]::ASCII.GetBytes('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')
    $binary_to_decode = [System.Text.Encoding]::ASCII.GetBytes($base58_encoded_string)
    $mapped = [byte[]]::New($binary_to_decode.length)
    for($i = 0; $i -lt $binary_to_decode.length; $i++)
    {
        $char = $binary_to_decode[$i]
        $mapped[$i] = $BASE58.IndexOf($char)
    }
    $decoded = [byte[]]::New($binary_to_decode.length)
    for($i = 0; $i -lt $mapped.length; $i++)
    {
        [System.Numerics.BigInteger]$b58_char = $mapped[$i]
        for($z = $binary_to_decode.length; $z -gt 0; $z--)
        {
            $b58_char = $b58_char + (58 * [Int32]::Parse($decoded[($z - 1)].ToString()))
            $decoded[($z - 1)] = $b58_char % 256
            $b58_char = $b58_char / 256
        }
    }
    $leading_zeroes = [regex]::New("^(0*)").Match([string]::Join([string]::Empty,$decoded)).Groups[1].Length
    (1..($leading_zeroes - $leading_ones)).ForEach({
        $decoded = $decoded[1..($decoded.Length - 1)]
    })
    if($output_plaintext)
    {
        $plaintext = [System.Text.Encoding]::ASCII.GetString($decoded)
        return $plaintext
    } else {
        $decoded_hex_string = [string]::Join([string]::Empty,@($decoded.ForEach({ $_.ToString('x2') })))
        return $decoded_hex_string
    }
}
