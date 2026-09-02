export class TrackRecord {
  id: string = ''
  title: string = ''
  placeName: string = ''
  note: string = ''
  startedAt: string = ''
  endedAt: string = ''
  durationSec: number = 0
  distanceM: number = 0
  status: string = 'manual'
}

export class TrackInsightSummary {
  totalTracks: number = 0
  totalDistanceKm: number = 0
  totalDurationHours: number = 0
  monthCount: number = 0
  topPlaces: string[] = []
  monthTrend: number[] = []
}

export class ManualTrackDraft {
  title: string = ''
  placeName: string = ''
  recordDate: string = ''
  distanceKm: string = ''
  durationMin: string = ''
  note: string = ''
}
