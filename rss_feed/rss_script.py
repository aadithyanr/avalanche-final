from fastapi import FastAPI
from fastapi.responses import Response
import datetime

app = FastAPI()

# Fake news articles storage
articles = [
    {
        "title": "Breaking: Fake News",
        "link": "https://example.com/fake-news-1",
        "description": "This is a fake news item for testing.",
        "pubDate": "Sun, 18 Feb 2024 12:00:00 GMT",
        "guid": "https://example.com/fake-news-1"
    },
    {
        "title": "Another Fake Headline",
        "link": "https://example.com/fake-news-2",
        "description": "This is another example item.",
        "pubDate": "Mon, 19 Feb 2024 08:00:00 GMT",
        "guid": "https://example.com/fake-news-2"
    }
]

@app.get("/rss.xml")
def generate_rss():
    xml_content = """<?xml version="1.0" encoding="UTF-8" ?>
    <rss version="2.0">
      <channel>
        <title>Dynamic Fake Feed</title>
        <link>https://example.com</link>
        <description>Generated RSS feed</description>
    """
    
    for article in articles:
        xml_content += f"""
        <item>
          <title>{article["title"]}</title>
          <link>{article["link"]}</link>
          <description>{article["description"]}</description>
          <pubDate>{article["pubDate"]}</pubDate>
          <guid>{article["guid"]}</guid>
        </item>
        """

    xml_content += """
      </channel>
    </rss>
    """
    return Response(content=xml_content, media_type="application/xml")

@app.post("/add_article")
def add_article(data: dict):
    if not all(k in data for k in ("title", "link", "description")):
        return {"error": "Missing required fields"}

    new_article = {
        "title": data["title"],
        "link": data["link"],
        "description": data["description"],
        "pubDate": datetime.datetime.utcnow().strftime("%a, %d %b %Y %H:%M:%S GMT"),
        "guid": data["link"]
    }

    articles.append(new_article)
    return {"message": "Article added successfully"}
