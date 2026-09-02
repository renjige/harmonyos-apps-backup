import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { WishItem, JournalStore } from '../../services/JournalStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'

class WishKind {
  id: string = 'person'
  label: string = '想了解的历史人物'
}

@Component
export struct WishlistPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State rows: WishItem[] = []
  @State title: string = ''
  @State kind: string = 'person'
  @State toastText: string = ''
  @State confirmId: string = ''
  private kinds: WishKind[] = WishlistPane.buildKinds()

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private static buildKinds(): WishKind[] {
    const a = new WishKind()
    const b = new WishKind()
    b.id = 'skill'
    b.label = '想学习的技能'
    const c = new WishKind()
    c.id = 'activity'
    c.label = '想尝试的活动'
    const list: WishKind[] = []
    list.push(a)
    list.push(b)
    list.push(c)
    return list
  }

  private reload(): void {
    this.rows = JournalStore.wishList()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('写下想探索的内容')
      return
    }
    await JournalStore.saveWish(this.title, this.kind)
    this.title = ''
    this.reload()
    this.showToast('已加入兴趣清单')
  }

  private async cycle(id: string): Promise<void> {
    await JournalStore.cycleWish(id)
    this.reload()
    this.showToast('进度已更新：未开始 → 进行中 → 已完成')
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点一次确认删除')
      return
    }
    await JournalStore.deleteWish(id)
    this.confirmId = ''
    this.reload()
    this.showToast('已从清单移除')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '兴趣清单',
        onClose: (): void => { PavilionDetailNav.close() }
      }) {
        Column({ space: Theme.space.s3 }) {
          Text('想探索的类型')
            .fontSize(13)
            .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.kinds, (k: WishKind) => {
              Text(k.label)
                .fontSize(13)
                .fontColor(this.kind === k.id ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.kind === k.id ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
                .borderRadius(8)
                .onClick((): void => { this.kind = k.id })
            }, (k: WishKind) => k.id)
          }
          .width('100%')
          TextInput({ text: this.title, placeholder: '例如：想了解的历史人物' })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
            .padding({ left: 14, right: 14 })
            .borderRadius(12)
            .border({ width: 1, color: Theme.hairline(this.themeEpoch, this.darkModeOn) })
            .onChange((v: string): void => { this.title = v })
          AppButton({ label: '加入清单', onTap: (): void => { void this.save() } })
          if (this.rows.length === 0) {
            AppEmpty({
              title: '清单还是空的',
              description: '把想了解、想学习和想尝试的事写下来，点条目切换进度。'
            })
          } else {
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.rows, (n: WishItem) => {
                  Column({ space: 6 }) {
                    Row() {
                      Text(n.statusLabel())
                        .fontSize(12)
                        .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .backgroundColor(Theme.brandBox(this.themeEpoch, this.darkModeOn))
                        .borderRadius(8)
                      Text(n.kindLabel())
                        .fontSize(12)
                        .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    Text(n.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                      .width('100%')
                    Text('点标题切换：未开始 → 进行中 → 已完成')
                      .fontSize(12)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                    Text(this.confirmId === n.id ? '再点一次删除' : '从清单删除')
                      .fontSize(12)
                      .fontColor(Theme.colors().danger)
                      .onClick((): void => { void this.remove(n.id) })
                  }
                  .width('100%')
                  .padding(12)
                  .alignItems(HorizontalAlign.Start)
                  .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                  .borderRadius(12)
                  .onClick((): void => { void this.cycle(n.id) })
                }, (n: WishItem) => n.id)
              }
              .padding({ bottom: Theme.space.s10 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .width('100%')
        .layoutWeight(1)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(20)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
