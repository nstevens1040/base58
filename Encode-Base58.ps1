function Encode-Base58
{
    [cmdletbinding()]
    Param(
        [string]$string_to_encode,
        [switch]$string_is_hexidecimal
    )
    $BASE58 = [System.Text.Encoding]::ASCII.GetBytes('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')
    if($string_is_hexidecimal)
    {
        $binary_to_encode = [byte[]]::New($string_to_encode.length / 2)
        for($i = 0; $i -lt $string_to_encode.length; $i+=2)
        {
            $binary_to_encode[$i/2] = [Convert]::ToByte($string_to_encode.SubString($i,2),16)
        }
    } else {
        $binary_to_encode = [System.Text.Encoding]::ASCII.GetBytes($string_to_encode)
    }
    $b58_size = 2*($binary_to_encode.length)
    $encoded = [byte[]]::New($b58_size)
    $leading_zeroes = [regex]::New("^(0*)").Match([string]::Join([string]::Empty,$binary_to_encode)).Groups[1].Length
    for($i = 0; $i -lt $binary_to_encode.length; $i++)
    {
        [System.Numerics.BigInteger]$dec_char = $binary_to_encode[$i]
        for($z = $b58_size; $z -gt 0; $z--)
        {
            $dec_char = $dec_char + (256 * $encoded[($z - 1)])
            $encoded[($z - 1)] = $dec_char % 58
            $dec_char = $dec_char / 58
        }
    }
    $mapped = [byte[]]::New($encoded.length)
    for($i = 0; $i -lt $encoded.length; $i++)
    {
        $mapped[$i] = $BASE58[$encoded[$i]]
    }
    $encoded_binary_string = [System.Text.Encoding]::ASCII.GetString($mapped)
    if([regex]::New("(1{$leading_zeroes}[^1].*)").Match($encoded_binary_string).Success)
    {
        return [regex]::New("(1{$leading_zeroes}[^1].*)").Match($encoded_binary_string).Groups[1].Value
    } else {
        write-host "errorenous: " + $encoded_binary_string -ForegroundColor Red
    }
}
