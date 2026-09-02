import { Theme } from '../design-system/Theme'
import { NotesToolChip } from './NotesToolChip'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct NotesLifeTools {
  @Prop wrapHint: string = ''
  @Prop todayMood: string = ''

  build() {
    Column({ space: Theme.space.s2 }) {
      Row({ space: Theme.space.s2 }) {
        NotesToolChip({
          title: '今日收束',
          hint: this.wrapHint,
          onTap: (): void => MomentNav.openDailyWrap()
        })
        NotesToolChip({
          title: '生活见解',
          hint: '本周对照 · 星标精选',
          onTap: (): void => MomentNav.openInsight()
        })
      }
      .width('100%')
      Row({ space: Theme.space.s2 }) {
        NotesToolChip({
          title: '心情轨迹',
          hint: this.todayMood.length > 0 ? `今日 ${this.todayMood}` : '近 14 日心情变化',
          onTap: (): void => MomentNav.openMoodTrend()
        })
        NotesToolChip({
          title: '纪念日',
          hint: '生日 · 节日 · 提醒',
          onTap: (): void => MomentNav.openMemorials()
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
