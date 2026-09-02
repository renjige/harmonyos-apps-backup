import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ThoughtCardView } from './ThoughtCardView'
import { ThoughtCard } from '../../models/ThoughtModels'
import { ThoughtStore } from '../../services/ThoughtStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct RecyclePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: ThoughtCard[] = []
  onBack: () => void = () => {}
  onOpenCard: (id: string) => void = (_id: string) => {}
  onChanged: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('返回')
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onBack() })
        Blank()
        Text('回收站')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      Text('删除 30 天后自动清理')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.items.length === 0) {
            AppEmpty({ title: '回收站是空的', description: '移入回收站的卡片会出现在这里' })
          } else {
            ForEach(this.items, (c: ThoughtCard) => {
              Column({ space: Theme.space.s2 }) {
                ThoughtCardView({
                  previewText: c.preview(),
                  tagsLabel: c.tagLine(),
                  shelfLabel: c.shelf,
                  timeLabel: DateHelper.formatShort(c.createdAt),
                  onOpen: (): void => { this.onOpenCard(c.id) }
                })
                Row({ space: Theme.space.s2 }) {
                  AppButton({
                    label: '还原',
                    variant: 'secondary',
                    onTap: (): void => {
                      void ThoughtStore.restore(c.id).then((): void => { this.onChanged() })
                    }
                  })
                  AppButton({
                    label: '彻底删除',
                    variant: 'danger',
                    onTap: (): void => {
                      void ThoughtStore.purge(c.id).then((): void => { this.onChanged() })
                    }
                  })
                }
              }
            }, (c: ThoughtCard) => `${c.id}|${c.updatedAt}|${c.tagsCsv}`)
          }
        }
        .padding({ bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
  }
}
