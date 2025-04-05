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

  # CNDS2025
  {
    id: 78,
    conference_id: 13,
    name: "Diamond",
    order: 1,
  },
  {
    id: 79,
    conference_id: 13,
    name: "Platinum",
    order: 2,
  },
  {
    id: 80,
    conference_id: 13,
    name: "Gold",
    order: 3,
  },
  {
    id: 81,
    conference_id: 13,
    name: "Booth",
    order: 4,
  },
  {
    id: 82,
    conference_id: 13,
    name: "Tool",
    order: 6,
  },
  {
    id: 83,
    conference_id: 13,
    name: "Support",
    order: 7,
  },
  {
    id: 84,
    conference_id: 13,
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

StampRallyCheckPointBooth.seed(
  {
    id: '01J9G65KEWB1NW637VDPWAA88W',
    conference_id: 12,
    sponsor_id: 1,
    name: "",
    description: "",
  },
  {
    id: '01J9G65KEZVCX8NKJXF3RB6PH5',
    conference_id: 12,
    sponsor_id: 2,
    name: "",
    description: "",
  }
)
StampRallyCheckPointFinish.seed(
  {
    id: '01J9G65KF4H9108RQ0ATRCT8H8',
    conference_id: 12,
    name: "",
    description: "",
  },
)
