import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { JianMedia } from '../../services/JianMedia'

@Component
export struct GenericDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop kind: string = 'thought'
  @Prop title: string = ''
  @Prop meta: string = ''
  @Prop summary: string = ''
  @Prop body: string = ''
  @Prop extra: string = ''
  @Prop favorite: boolean = false
  onEdit: () => void = () => {}
  onFavorite: () => void = () => {}
  onDelete: () => void = () => {}
  onExtraAction: () => void = () => {}
  @Prop extraActionLabel: string = ''

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(JianMedia.coverFor(this.kind))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(88)
              .linearGradient({
                angle: 180,
                colors: [['rgba(18,38,47,0)', 0], ['rgba(18,38,47,0.78)', 1]]
              })
            Column({ space: 4 }) {
              Text(this.meta)
                .fontSize(Theme.type.caption)
                .fontColor('#F6F1E8')
              Text(this.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F1E8')
                .maxLines(2)
            }
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          if (this.summary.length > 0) {
            AppCard({ title: '摘要', variant: 'plain' }) {
              Text(this.summary)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(24)
            }
          }

          if (this.body.length > 0) {
            AppCard({ title: '正文', variant: 'plain' }) {
              Text(this.body)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .lineHeight(24)
            }
          }

          if (this.extra.length > 0) {
            AppCard({ title: '补充', variant: 'plain' }) {
              Text(this.extra)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .lineHeight(24)
            }
          }

          AppButton({
            label: '编辑',
            variant: 'primary',
            onTap: (): void => { this.onEdit() }
          })
          AppButton({
            label: this.favorite ? '取消收藏' : '收藏进观点库',
            variant: 'secondary',
            onTap: (): void => { this.onFavorite() }
          })
          if (this.extraActionLabel.length > 0) {
            AppButton({
              label: this.extraActionLabel,
              variant: 'ghost',
              onTap: (): void => { this.onExtraAction() }
            })
          }
          AppButton({
            label: '删除',
            variant: 'danger',
            onTap: (): void => { this.onDelete() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10,
          top: Theme.space.s2
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
