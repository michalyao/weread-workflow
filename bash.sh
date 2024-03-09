#!/bin/bash

# 读取剪贴板内容
clipboard_content=$(pbpaste)

# 初始化变量
book=""
author=""
notecount=""
body_started=false
final_content=""

# 将剪贴板内容按行读取并处理
while IFS= read -r line || [[ -n "$line" ]]; do
    # 检查是否已收集所有头部信息
    if [[ -n "$book" && -n "$author" && -n "$notecount" ]]; then
        body_started=true
    fi

    if [[ $body_started == false ]]; then
        if [[ -n "$line" && -z "$book" ]]; then
            # 提取书名，去除两侧的《》
            book=$(echo "$line" | sed 's/^《\(.*\)》$/\1/')
            final_content+="  book:: $book\n"
            continue
        elif [[ -n "$line" && -z "$author" ]]; then
            # 提取作者
            author="$line"
            final_content+="  author:: $author\n"
            continue
        elif [[ -n "$line" && -z "$notecount" ]]; then
            # 提取笔记数
            notecount="$line"
            final_content+="  notecount:: $notecount\n"
            continue
        fi
    else
        # 处理正文部分
        if [[ $line =~ ^第.*章 ]]; then
            final_content+="\n- ### $line"
        elif [[ $line == "◆ "* ]]; then
            note_content="${line:2}"
            final_content+="\n\t- $note_content"
        fi
    fi
done <<< "$clipboard_content"

# 将处理后的内容写回剪贴板
echo "$final_content" | pbcopy

echo "Content adjusted and copied to clipboard."