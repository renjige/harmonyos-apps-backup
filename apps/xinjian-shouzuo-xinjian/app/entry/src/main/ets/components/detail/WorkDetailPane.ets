import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { HandcraftWork } from '../../models/HandcraftModels'
import { HandcraftBizService } from '../../services/HandcraftBizService'
import { CraftMedia } from '../../services/CraftMedia'
import { CraftDetailNav } from '../../services/CraftDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct WorkDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop workId: string = ''
  @Prop @Watch('onWorkIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State work: HandcraftWork | undefined = undefined
  @State favorited: boolean = false
  @State loading: boolean = true
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.loadAll()
  }

  onWorkIdChange(): void {
    void this.loadAll()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadAll(): Promise<void> {
    this.loading = true
    const w = await HandcraftBizService.findWork(this.workId)
    this.work = w
    if (w !== undefined) {
      const inter = await HandcraftBizService.loadInteractions(this.workId)
      this.favorited = inter.favorited
    }
    this.loading = false
  }

  private async handleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('favorite')) {
      this.onRequireAuth()
      return
    }
    const res = await HandcraftBizService.toggleFavorite(this.workId)
    if (res !== undefined) {
      this.favorited = res.favorited
      this.showToast(res.favorited ? '已加入收藏夹' : '已取消收藏')
      this.onChanged()
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载作品…' })
      } else if (this.work === undefined) {
        AppEmpty({ title: '作品不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: this.work.title,
          onClose: () => CraftDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.work === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(CraftMedia.byKey(this.work.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(61,58,54,0)', 0], ['rgba(61,58,54,0.72)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.work.category)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.work.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.work.userId === 'curator') {
          Row() {
            Text('心笺官方课堂')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: this.favorited ? '已收藏' : '加入收藏清单',
              variant: this.favorited ? 'secondary' : 'primary',
              onTap: (): void => { void this.handleFavorite() }
            })
          }.layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '作品摘要', variant: 'plain' }) {
            Text(this.work.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '制作说明', variant: 'plain' }) {
            Text(this.work.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.work.materials.length > 0) {
          Column() {
            AppCard({ title: '材料清单', variant: 'outlined' }) {
              Column({ space: 6 }) {
                ForEach(this.work.materials, (m: string) => {
                  Row({ space: 8 }) {
                    AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandDeep })
                    Text(m).fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  }.width('100%')
                }, (m: string) => m)
              }.width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.work.steps.length > 0) {
          Column() {
            AppCard({ title: '制作步骤', variant: 'outlined' }) {
              Scroll() {
                Column({ space: 10 }) {
                  ForEach(this.work.steps, (step: string, idx: number) => {
                    Row({ space: 10 }) {
                      Text(`${idx + 1}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandOnPrimary)
                        .textAlign(TextAlign.Center)
                        .width(24)
                        .height(24)
                        .backgroundColor(Theme.colors().brandDeep)
                        .borderRadius(Theme.radius.pill)
                      Text(step)
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .layoutWeight(1)
                        .lineHeight(22)
                    }.width('100%').alignItems(VerticalAlign.Top)
                  }, (step: string, idx: number) => `${idx}_${step}`)
                }
                .width('100%')
                .padding({ bottom: Theme.space.s2 })
              }
              .width('100%')
              .height(320)
              .scrollBar(BarState.Auto)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.work.notes.length > 0) {
          Column() {
            AppCard({ title: '创作心得', variant: 'glass' }) {
              Text(this.work.notes)
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
