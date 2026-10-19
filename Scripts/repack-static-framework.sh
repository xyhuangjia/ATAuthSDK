#!/bin/bash
# 将静态 .framework 的全部目标文件合并为单个可重定位对象（ld -r），
# 使 ObjC 分类无法被链接器按成员裁剪——业务方无需再设置 -ObjC。
# 用法: repack-static-framework.sh /path/to/Some.framework
set -euo pipefail

FW="$1"
FW=$(cd "$(dirname "$FW")" && pwd)/$(basename "$FW")
NAME=$(basename "$FW" .framework)
BIN="$FW/$NAME"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

echo ">> $NAME"

# 1) 拆分出各架构的瘦库（输入本身是瘦库时直接使用）
THINS=()
ARCHS=($(/usr/bin/lipo -archs "$BIN" | tr -s ' ' '\n' | grep -v '^$'))
if lipo -info "$BIN" | grep -q "Non-fat file"; then
    THINS=("$BIN")
else
    for arch in "${ARCHS[@]}"; do
        out="$WORK/$NAME.$arch.a"
        lipo "$BIN" -thin "$arch" -output "$out"
        THINS+=("$out")
    done
fi

# 2) 每个架构：解包 -> ld -r 合并 -> 重打包
declare -a MERGED=()
for idx in "${!THINS[@]}"; do
    arch="${ARCHS[$idx]}"
    thin="${THINS[$idx]}"
    ex="$WORK/extract_$arch"
    mkdir -p "$ex"
    (cd "$ex" && ar x "$thin")
    objs=("$ex"/*.o)
    count=${#objs[@]}
    merged="$WORK/$NAME.$arch.merged.o"
    case "$arch" in
        x86_64|arm64_x86_64-simulator) plat=ios-simulator ;;
        *) plat=ios ;;
    esac
    sdk_ver=$(xcrun --sdk iphoneos --show-sdk-version 2>/dev/null || echo 9.0)
    xcrun ld -r -arch "$arch" -platform_version "$plat" 9.0 "$sdk_ver" -o "$merged" "${objs[@]}"
    newa="$WORK/$NAME.$arch.repacked.a"
    libtool -static -no_warning_for_no_symbols -o "$newa" "$merged"
    MERGED+=("$newa")
    echo "   [$arch] 成员 $count -> 单对象 $(du -h "$merged" | cut -f1)"
done

# 3) 合成回 fat 二进制并替换
if [ ${#MERGED[@]} -eq 1 ]; then
    cp "${MERGED[0]}" "$BIN"
else
    lipo -create -output "$BIN" "${MERGED[@]}"
fi
echo "   已替换 $BIN"
