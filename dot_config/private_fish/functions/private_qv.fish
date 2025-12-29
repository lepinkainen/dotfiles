function qv --description "Ask questions about YouTube video content via subtitles"
    set -l url $argv[1]
    set -l question $argv[2..-1]

    # Default question if none provided
    if test -z "$question"
        set question "Summarize this video in a clear, well-formatted way for reading in a terminal. Use markdown formatting with bullet points where appropriate. Include the main topics and key takeaways."
    end

    # Fetch the URL content through Jina
    set -l subtitle_url (yt-dlp -q --skip-download --convert-subs srt --write-sub --sub-langs "en" --write-auto-sub --print "requested_subtitles.en.url" "$url")
    set -l content (curl -s "$subtitle_url" | sed '/^$/d' | grep -v '^[0-9]*$' | grep -v '\-->' | sed 's/<[^>]*>//g' | tr '\n' ' ')

    # Check if the content was retrieved successfully
    if test -z "$content"
        echo "Failed to retrieve content from the URL."
        return 1
    end

    set -l system "
    You are a helpful assistant that can answer questions about YouTube videos.
    Reply concisely but comprehensively, using markdown formatting for readability.

    The content:
    $content
    "

    # Use llm with the fetched content as a system prompt
    llm prompt "$question" -s "$system"
end
