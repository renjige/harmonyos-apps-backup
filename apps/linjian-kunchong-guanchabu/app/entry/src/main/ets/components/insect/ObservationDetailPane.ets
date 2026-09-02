import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from '../detail/DetailShell'
import { Observation, WeatherOption } from '../../models/ObservationModels'
import { ObservationStore } from '../../services/ObservationStore'
import { InsectMedia } from '../../services/InsectMedia'

@Component
export struct ObservationDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop obsId: string = ''
  onBack: () => void = () => {}
  onEdit: () => void = () => {}
  onDeleted: () => void = () => {}
  @State item: Observation = new Observation()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await ObservationStore.findById(this.obsId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private async toggleFav(): Promise<void> {
    this.item.isFavorite = !this.item.isFavorite
    await ObservationStore.save(this.item)
  }

  private async doDelete(): Promise<void> {
    await ObservationStore.remove(this.item.id)
    this.confirmDelete = false
    this.onDeleted()
    this.onBack()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.item.name.length > 0 ? this.item.name : '观察详情',
        showFavorite: true,
        favorite: this.item.isFavorite,
        onBack: (): void => this.onBack(),
        onFavorite: (): void => { void this.toggleFav() }
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.item.photoUri.length > 0) {
                Image(this.item.photoUri)
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
              } else {
                Image(InsectMedia.cover('hero_leaf_dew'))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
              }
              Column() {
                Text(this.item.name)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(`${this.item.date} ${this.item.time}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(16)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(16,32,24,0.78)', 1]]
              })
            }
            .width('100%')
            .borderRadius(Theme.radius.lg)
            .clip(true)

            Text(`${WeatherOption.labelOf(this.item.weather)} · ${this.item.location.length > 0 ? this.item.location : '未填写地点'}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            AppCard({ title: '行为描述' }) {
              Text(this.item.behavior.length > 0 ? this.item.behavior : '未填写行为描述')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(22)
                .width('100%')
            }

            if (this.item.tagsJoined().length > 0) {
              Text(this.item.tagsJoined())
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
            }

            AppButton({ label: '编辑', variant: 'secondary', onTap: (): void => this.onEdit() })
            AppButton({ label: '删除此记录', variant: 'danger', onTap: (): void => { this.confirmDelete = true } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('删除后无法恢复，确认删除这条观察？')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
        }
        .width('80%')
        .padding(Theme.space.s6)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .margin({ top: 160 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
