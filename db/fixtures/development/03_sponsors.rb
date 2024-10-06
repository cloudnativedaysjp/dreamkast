SponsorType.seed(
  {
    id: 71,
    conference_id: 12,
    name: "Diamond",
    order: 1,
  },
  {
    id: 72,
    conference_id: 12,
    name: "Platinum",
    order: 2,
  },
  {
    id: 73,
    conference_id: 12,
    name: "Gold",
    order: 3,
  },
  {
    id: 74,
    conference_id: 12,
    name: "Booth",
    order: 4,
  },
  {
    id: 75,
    conference_id: 12,
    name: "Tool",
    order: 6,
  },
  {
    id: 76,
    conference_id: 12,
    name: "Support",
    order: 7,
  },
  {
    id: 77,
    conference_id: 12,
    name: "CM",
    order: 5,
  },
)

Sponsor.seed(
  {
    id: 1,
    abbr: "booth1",
    conference_id: 12,
    name: "Booth Sponsor 1",
    url: "https://example.com",
    description: "Booth Sponsor 1",
  },
  {
    id: 2,
    abbr: "booth2",
    conference_id: 12,
    name: "Booth Sponsor 2",
    url: "https://example.com",
    description: "Booth Sponsor 2",
  },
)

StampRallyDefBooth.seed(
  {
    conference_id: 12,
    sponsor_id: 1,
  },
  {
    conference_id: 12,
    sponsor_id: 2,
  }
)
StampRallyDefFinish.seed(
  {
    conference_id: 12
  },
)
