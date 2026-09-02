import { TrackInsightSummary, TrackRecord } from '../models/TrackModels'
import { TrackStore } from './TrackStore'

export class TrackAnalytics {
  static summarize(): TrackInsightSummary {
    const summary = new TrackInsightSummary()
    const tracks = TrackStore.list()
    summary.totalTracks = tracks.length
    const now = new Date()
    const monthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
    const trend: number[] = []
    for (let i = 5; i >= 0; i--) {
      trend.push(0)
    }
    const placeKeys: string[] = []
    const placeCounts: number[] = []

    for (const tr of tracks) {
      summary.totalDistanceKm += tr.distanceM / 1000
      summary.totalDurationHours += tr.durationSec / 3600
      if (tr.startedAt.startsWith(monthKey)) {
        summary.monthCount += 1
      }
      const monthIdx = TrackAnalytics.monthBucket(tr.startedAt)
      if (monthIdx >= 0 && monthIdx < 6) {
        trend[monthIdx] += 1
      }
      if (tr.placeName.length > 0) {
        TrackAnalytics.bumpPlace(placeKeys, placeCounts, tr.placeName)
      }
    }

    summary.monthTrend = trend
    summary.topPlaces = TrackAnalytics.topPlaces(placeKeys, placeCounts, 5)
    return summary
  }

  private static monthBucket(iso: string): number {
    try {
      const d = new Date(iso)
      const now = new Date()
      const diff = (now.getFullYear() - d.getFullYear()) * 12 + (now.getMonth() - d.getMonth())
      if (diff < 0 || diff > 5) {
        return -1
      }
      return 5 - diff
    } catch {
      return -1
    }
  }

  private static bumpPlace(keys: string[], counts: number[], key: string): void {
    for (let i = 0; i < keys.length; i++) {
      if (keys[i] === key) {
        counts[i] += 1
        return
      }
    }
    keys.push(key)
    counts.push(1)
  }

  private static topPlaces(keys: string[], counts: number[], limit: number): string[] {
    const idx: number[] = []
    for (let i = 0; i < keys.length; i++) {
      idx.push(i)
    }
    idx.sort((a: number, b: number) => counts[b] - counts[a])
    const out: string[] = []
    for (let i = 0; i < idx.length && out.length < limit; i++) {
      out.push(keys[idx[i]])
    }
    return out
  }
}
