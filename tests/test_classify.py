from skemman_scraper.classify import classify_external_involvement, classify_topic


def test_topic_classification():
    topic, confidence = classify_topic(
        "This thesis uses machine learning for fisheries forecasting.",
        {"ai": ["machine learning"], "energy": ["energy"]},
    )
    assert topic == "ai"
    assert confidence > 0.8


def test_external_classification():
    code, actor_type, actor_name, evidence, confidence = classify_external_involvement(
        "The project was carried out in collaboration with Marel.",
        {"collaboration": ["in collaboration with"], "companies": ["Marel"]},
    )
    assert code >= 3
    assert actor_type == "company"
    assert actor_name == "Marel"
    assert evidence
    assert confidence > 0.8
