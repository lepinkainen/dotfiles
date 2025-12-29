# Use llm to get a summary of a Hacker News item given its URL
# ~/.config/fish/functions/hnsummary.fish
function hnsummary --description "Summarize a Hacker News thread using llm"
    if test (count $argv) -ne 1
        echo "usage: hnsummary <hn item url>"
        return 1
    end

    set url $argv[1]

    # Extract id=NNNNN from the URL
    set id (string match -r 'id=([0-9]+)' $url | string replace -r '.*id=([0-9]+)' '$1')

    if test -z "$id"
        echo "Could not extract HN item id from URL"
        return 1
    end

    set prompt "
Summarize the Hacker News discussion.

Requirements:
- Focus on the main technical and factual points raised by commenters.
- Capture points of disagreement or controversy.
- Include 3–6 short, illustrative direct quotes (verbatim), attributed generically (e.g. “one commenter”).
- Avoid fluff, meta commentary, or praise.
- Do not invent facts or quotes.

Output format:
- 3–6 bullet points for the summary
- Then a \"Notable quotes\" section with the quotes and relevant context.
"

    llm -f hn:$id -s "$prompt"
end
