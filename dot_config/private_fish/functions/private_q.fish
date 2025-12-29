function q --description "Ask questions about URL content via Jina AI"
    set -l url $argv[1]
    set -l question $argv[2..-1]

    # Default question if none provided
    if test -z "$question"
        set question "Summarize this article in a clear, well-formatted way for reading in a terminal. Use markdown formatting with bullet points where appropriate. Include the main ideas and key points."
    end

    # Fetch the URL content through Jina
    set -l content (curl -s "https://r.jina.ai/$url")

    # Check if the content was retrieved successfully
    if test -z "$content"
        echo "Failed to retrieve content from the URL."
        return 1
    end

    set -l system "
    You are a helpful assistant that can answer questions about the content.
    Reply concisely but comprehensively, using markdown formatting for readability.

    The content:
    $content
    "

    # Use llm with the fetched content as a system prompt
    llm prompt "$question" -s "$system"
end
